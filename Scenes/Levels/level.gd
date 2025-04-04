class_name Level
extends Node2D

@onready var projectiles: Node = $Projectiles
@onready var enemies: Path2D = $Enemies
@onready var towers: Node = $Towers
@onready var build_timer: Timer = $Timers/BuildTimer
@onready var ui: CanvasLayer = $ui

var buildmode: bool = false
var currently_building: Tower
var tower_array = []

func _ready() -> void:
	MultiplayerManager.player_loaded.rpc_id(1) # Tell the server that this peer has loaded
	get_towers()
	ui.connect("start_wave",start_wave)
	enemies.connect("spawn_enemy",create_enemy)
	enemies.connect("wave_complete",wave_complete)
	
	if (get_tree().get_nodes_in_group("Players").size() < 1) and MultiplayerManager.multiplayer_mode == false:
		var player = preload("res://Scenes/player.tscn").instantiate()
		add_child(player)

func get_towers():
	for tower in get_tree().get_nodes_in_group("Towers"):
		if not tower_array.has(tower):
			tower_array.append(tower)
			tower.connect("shoot",create_projectile)

func _input(event: InputEvent) -> void:
	if buildmode:
		if event.is_action_released("action") and currently_building.canbuild:
			build_tower()
		if event.is_action_released("cancel"):
			currently_building.queue_free()
			buildmode = false

func build_tower():
	if Globals.money >= currently_building.cost:
		currently_building.buildmode = false
		currently_building.range_color = Color.TRANSPARENT
		currently_building.state_changer.play("RESET")
		currently_building.queue_redraw()
		Globals.money -= currently_building.cost
		get_towers()
		buildmode = false
	else:
		print("Can't Afford")

func create_projectile(projectile_type,pos,target,attacker,dmg):
	var projectile = projectile_type.instantiate() as Projectile
	projectile.position = pos
	projectile.target = target
	projectile.attacker = attacker
	projectile.damage = dmg
	projectiles.add_child(projectile)

func start_wave():
	Globals.wave_in_progress = true
	Globals.wave_finished_spawning = false
	enemies.spawn_wave()

func wave_complete():
	Globals.wave_finished_spawning = true

func create_enemy(enemy_scene:PackedScene):
	var enemy = enemy_scene.instantiate()
	enemy.connect("finished",enemy_finished)
	enemy.connect("effect_added",enemy_add_effect)
	enemies.add_child(enemy)

func enemy_finished(dmg:int):
	Globals.health -= dmg

func enemy_add_effect(target:Node,effect:PackedScene):
	var new_effect = effect.instantiate()
	target.add_child.call_deferred(new_effect)

func _on_build_timer_timeout() -> void:
	buildmode = true

func _on_ui_twr_btn_pressed(scene:PackedScene) -> void:
	# Create a Tower when the Button is pressed
	if not buildmode:
		currently_building = scene.instantiate() as Tower
		currently_building.buildmode = true
		currently_building.canbuild = true
		currently_building.position = get_global_mouse_position()
		towers.add_child(currently_building)
		build_timer.start()
