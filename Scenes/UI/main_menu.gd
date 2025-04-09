extends MarginContainer

var use_steam:bool = false
var server_ip:String = "127.0.0.1"

signal load_level()
signal show_multiplayer_lobby

func _load_level():
	load_level.emit()

#region MenuPnl
func _on_singleplayer_btn_pressed() -> void:
	%LevelSelectPnl.show()

func _on_multiplayer_btn_pressed() -> void:
	%MenuPnl.hide()
	%MultiplayerPnl.show()

func _on_options_btn_pressed() -> void:
	print("This button doesn't do anything yet!")

func _on_exit_btn_pressed() -> void:
	print("Exiting game...")
	get_tree().quit()
#endregion

func _on_back_btn_pressed() -> void:
	%LevelSelectPnl.hide()
	%MultiplayerPnl.hide()
	%MenuPnl.show()

func _on_ip_back_btn_pressed() -> void:
	%EnetPnl.hide()
	%MultiplayerPnl.show()

func _on_enet_btn_pressed() -> void:
	%MultiplayerPnl.hide()
	%EnetPnl.show()

func _on_steam_check_toggled(toggled_on: bool) -> void:
	use_steam = toggled_on
	print("Use Steam set to %s" % str(toggled_on))

func _on_host_back_btn_pressed() -> void:
	%HostPnl.hide()
	%MultiplayerPnl.show()

func _on_host_btn_pressed() -> void:
	%MultiplayerPnl.hide()
	%HostPnl.show()

func _on_create_lobby_btn_pressed() -> void:
	if not use_steam:
		print("Becoming host...")
		MultiplayerManager.become_host()
		show_multiplayer_lobby.emit()
	else:
		print("Becoming host using Steam...")
		print("NOTE: Steam is not set up")

func _on_connect_btn_pressed() -> void:
	print("Connecting as client...")
	MultiplayerManager.join_as_client(server_ip)
	show_multiplayer_lobby.emit()

func _on_ip_text_changed(new_text: String) -> void:
	server_ip = new_text

func _set_name(text: String) -> void:
	MultiplayerManager.player_info.player_name = text
