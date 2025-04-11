extends MarginContainer

var lobby_item = preload("res://Scenes/UI/lobby_item.tscn")
signal back
signal start_game

func _ready() -> void:
	multiplayer.peer_connected.connect(update_lobby_players)
	update_lobby_players()

func update_lobby_players(_id=1):
	if MultiplayerManager.players.size() > 0:
		for child in $Panel/VBoxContainer/Players.get_children():
			if child.name != "LobbyItem" and child.name != "HSeparator":
				child.queue_free()
	for player in MultiplayerManager.players:
		add_player_to_lobby(player,MultiplayerManager.players[player].player_name)

func add_player_to_lobby(player_id, player_name):
	var new_player = lobby_item.instantiate()
	new_player.player_name = player_name
	new_player.player_id = player_id
	$Panel/VBoxContainer/Players.add_child(new_player)

func _on_refresh_timer_timeout() -> void:
	update_lobby_players()
	if not MultiplayerManager.is_host:
		$Panel/VBoxContainer/BtnContainer/LevelSelectBtn.hide()
		$Panel/VBoxContainer/BtnContainer/StartBtn.hide()
	else:
		$Panel/VBoxContainer/BtnContainer/LevelSelectBtn.show()
		$Panel/VBoxContainer/BtnContainer/StartBtn.show()

func _on_level_select_btn_pressed() -> void:
	$Panel/LevelSelectPnl.show()


func _on_back_btn_pressed() -> void:
	back.emit()

func _on_start_btn_pressed() -> void:
	start_game.emit()
