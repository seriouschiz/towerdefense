extends Node

var levels = {
	"Level 1":preload("res://Scenes/Levels/level_01.tscn"),
}

var enemies = {
	"blue_slime":preload("res://Scenes/Enemies/blue_slime.tscn"),
	"red_slime":preload("res://Scenes/Enemies/red_slime.tscn"),
}

var effects = {
	"burning":preload("res://Scenes/Effects/effect_burning.tscn"),
}

var towers = {
		"basic_turret":preload("res://Scenes/Towers/basic_turret.tscn"),
		"ballista":preload("res://Scenes/Towers/ballista.tscn"),
		"fire_tower":preload("res://Scenes/Towers/fire_tower.tscn"),
		}

var projectiles = {
	"bullet":preload("res://Scenes/Projectiles/bullet.tscn"),
	"arrow":preload("res://Scenes/Projectiles/arrow.tscn"),
	"fire_ring":preload("res://Scenes/Projectiles/fire_ring.tscn"),
}
