extends Panel

signal load_level

const LEVEL_BTN = preload("res://Scenes/UI/Buttons/level_btn.tscn")
var default_lvl

func _ready() -> void:
	for level in Game.levels:
			var lvl_btn = LEVEL_BTN.instantiate()
			lvl_btn.text = level
			lvl_btn.level = Game.levels[level]
			if level == null:
				Globals.selected_level = Game.levels[level]
			$LevelGrid.add_child(lvl_btn)
			lvl_btn.lvl_btn.connect(_select_level)

func _select_level(lvl:PackedScene):
	print("Selecting level %s" % lvl)
	Globals.selected_level = lvl
	print("Selected level = %s" % Globals.selected_level)

func _on_back_btn_pressed() -> void:
	hide()

func _on_load_btn_pressed() -> void:
	load_level.emit()
