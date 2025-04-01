extends Node

const SERVER_PORT = 8080
var player_scene = preload("res://Scenes/player.tscn")

var _players_spawn_node

func become_host():
	print("Starting host!")
	
	_players_spawn_node = get_tree().get_current_scene().get_node("Players")
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_player_connected_to_game)
	multiplayer.peer_disconnected.connect(_player_disconnected_from_game)
	
	_player_connected_to_game(1) # Adds the host player to the scene

func join_as_client(ip:String):
	print("Joining as client.")
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(ip,SERVER_PORT)
	
	multiplayer.multiplayer_peer = client_peer

func _player_connected_to_game(id: int):
	print("Player %s connected." % id)
	
	var player_to_add = player_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	_players_spawn_node.add_child(player_to_add)

func _player_disconnected_from_game(id: int):
	print("Player %s disconnected." % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()
