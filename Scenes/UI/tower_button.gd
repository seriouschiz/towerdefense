extends Button

var scene: PackedScene

signal twr_btn(scene:PackedScene)

func _pressed() -> void:
	twr_btn.emit(scene)
