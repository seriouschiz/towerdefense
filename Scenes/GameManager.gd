extends Node


func _on_main_menu_load_level() -> void:
	print("ON LOAD LEVEL Selected Level = %s" % Globals.selected_level)
	if Globals.selected_level:
		print("Loading level: %s" % Globals.selected_level)
		var lvl_to_load = Globals.selected_level.instantiate()
		$MainMenu.queue_free()
		$Level.add_child(lvl_to_load)
	else:
		print("No level selected: %s" % Globals.selected_level)

func _on_multiplayer_lobby_start_game() -> void:
	_on_main_menu_load_level()

func _on_main_menu_show_multiplayer_lobby() -> void:
	$MainMenu.hide()
	$MultiplayerLobby.show()

func _on_multiplayer_lobby_back() -> void:
	$MultiplayerLobby.hide()
	$MainMenu.show()


func start_game():
	print("Starting Game!")
	_on_main_menu_load_level()
