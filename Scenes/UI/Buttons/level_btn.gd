extends Button

var level: PackedScene

signal lvl_btn(level:PackedScene)

func _pressed() -> void:
	lvl_btn.emit(level)
