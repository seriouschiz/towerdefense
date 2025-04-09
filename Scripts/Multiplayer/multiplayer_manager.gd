extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal update_ui

const SERVER_PORT = 8080
const DEFAULT_SERVER_IP = "127.0.0.1"
var player_scene = preload("res://Scenes/player.tscn")
var player_spawn_node

var lobby_size:int = 2

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This is set by the _set_name function in main_menu.gd
var player_info = {"player_name": "Name" , "money": Globals.starting_money}:
	set(value):
		player_info = value
		update_player_info.rpc(value)

var players_loaded: int = 0
var is_host: bool = false
var multiplayer_mode = false

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	player_spawn_node = get_tree().get_first_node_in_group("PlayerSpawnNode")

@rpc
func update_player_info(new_info):
	player_info = new_info

func spawn_players():
	for player in players:
		var new_player = player_scene.instantiate()
		new_player.name = str(player)
		new_player.player_name = players[player].player_name
		new_player.player_id = int(player)
		player_spawn_node.add_child(new_player)
	update_ui.emit()

func become_host():
	print("Starting host!")
	#_players_spawn_node = get_tree().get_first_node_in_group("PlayerSpawnNode")
	#print(get_tree().get_first_node_in_group("PlayerSpawnNode"))
	
	var server_peer = ENetMultiplayerPeer.new()
	var error = server_peer.create_server(SERVER_PORT)
	if error:
		return error
	
	multiplayer.multiplayer_peer = server_peer
	is_host = true
	multiplayer_mode = true
	print("Is host = %s" % is_host)
	players[1] = player_info
	player_connected.emit(1, player_info)

func join_as_client(ip:String):
	print("Joining as client.")
	if ip.is_empty():
		ip = DEFAULT_SERVER_IP
	var client_peer = ENetMultiplayerPeer.new()
	var error = client_peer.create_client(ip,SERVER_PORT)
	if error:
		return error
	
	multiplayer.multiplayer_peer = client_peer
	multiplayer_mode = true

func _on_player_connected(id: int):
	print("Player %s connected." % id)
	
	_register_player.rpc_id(id, player_info)
	
	#var player_to_add = player_scene.instantiate()
	#player_to_add.player_id = id
	#player_to_add.name = str(id)
	#
	#_players_spawn_node = get_tree().get_first_node_in_group("PlayerSpawnNode")
	#_players_spawn_node.add_child(player_to_add)

func _on_player_disconnected(id: int):
	print("Player %s disconnected." % id)
	players.erase(id)
	player_disconnected.emit(id)
	#if not _players_spawn_node.has_node(str(id)):
		#return
	#_players_spawn_node.get_node(str(id)).queue_free()

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	players.clear()

# When the server decides to start the game from a UI scene,
# do MultiplayerManager.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)

# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		print("Players loaded: %s" % players_loaded)
		print(players)
		if players_loaded == lobby_size:
			spawn_players()

@rpc("any_peer","reliable")
func _register_player(new_player_info):
	print("Registering player...")
	print(str("ID: ",multiplayer.get_remote_sender_id()," Name: ",new_player_info))
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	players.sort()
	player_connected.emit(new_player_id, new_player_info)

func _on_connected_ok():
	print("_on_connected_ok")
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id,player_info)

func _on_connected_fail():
	print("_on_connected_fail")
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	print("_on_server_disconnected")
	multiplayer.multiplayer_peer = null
	multiplayer_mode = true
	players.clear()
	server_disconnected.emit()
