extends Node

func _on_main_menu_load_level(lvl: PackedScene) -> void:
	var lvl_to_load = lvl.instantiate()
	$MainMenu.queue_free()
	self.add_child(lvl_to_load)

func _on_main_menu_show_multiplayer_lobby() -> void:
	$MainMenu.hide()
	$MultiplayerLobby.show()
