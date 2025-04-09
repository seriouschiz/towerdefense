extends Node

signal player_stat_change()
signal no_health()

var player_name: String
var starting_money: int = 200

var selected_level: PackedScene:
	set(lvl):
		selected_level = lvl
		print("SET Selected Level = %s" % lvl)

var health: int = 20:
	set(value):
		if value > max_health:
			health = max_health
		else:
			health = value
		player_stat_change.emit()
		if health == 0:
			no_health.emit()
var money: int = 300:
	set(value):
		if value < 0:
			money = 0
		else:
			money = value
		player_stat_change.emit()

var enemies_alive: int = 0:
	set(value):
		if value < 0:
			enemies_alive = 0
		else:
			enemies_alive=value
		if enemies_alive == 0:
			wave_in_progress = false
		player_stat_change.emit()

var wave_in_progress: bool = false
var wave_finished_spawning: bool = true

var max_health: int = 20

# Moved to Game.gd
#var enemy_types = {
	#"blue_slime":preload("res://Scenes/Enemies/blue_slime.tscn"),
	#"red_slime":preload("res://Scenes/Enemies/red_slime.tscn"),
#}
#
#var effects = {
	#"burning":preload("res://Scenes/Effects/effect_burning.tscn"),
#}
