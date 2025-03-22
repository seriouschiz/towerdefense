class_name Effect

extends Node

var target
var duration: float
var tickrate: float
var attacker: String
@export var dmg_name: String

func _ready() -> void:
	target = get_parent()

func _tick_effect():
	pass

func _duration_end():
	pass

func _on_duration_timeout() -> void:
	_duration_end()
	queue_free()

func _on_tick_timeout() -> void:
	_tick_effect()
