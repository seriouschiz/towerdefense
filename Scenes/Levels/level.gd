class_name Level
extends Node2D

@onready var projectiles: Node = $Projectiles
@onready var enemies: Path2D = $Enemies
@onready var towers: Node = $Towers
@onready var currently_building_node: Node = $CurrentlyBuilding
@onready var build_timer: Timer = $Timers/BuildTimer
@onready var ui: CanvasLayer = $ui

var buildmode: bool = false
var currently_building: Tower
var tower_type: String
var tower_array = []

var id

func _ready() -> void:
	MultiplayerManager.player_loaded.rpc_id(1) # Tell the server that this peer has loaded
	get_towers()
	prepare_spawners()
	id = multiplayer.get_unique_id()
	ui.connect("start_wave",start_wave)
	enemies.connect("spawn_enemy",create_enemy)
	enemies.connect("wave_complete",wave_complete)

	if (get_tree().get_nodes_in_group("Players").size() < 1) and MultiplayerManager.multiplayer_mode == false:
		var player = preload("res://Scenes/player.tscn").instantiate()
		player.player_id = 1
		add_child(player)

func get_towers():
	if not multiplayer.is_server():
		return
	
	for tower in get_tree().get_nodes_in_group("Towers"):
		if not tower_array.has(tower):
			tower_array.append(tower)
			tower.connect("shoot",create_projectile)

func prepare_spawners():
	get_tower_types()
	get_enemy_types()
	#get_projectile_types()

func get_tower_types():
	for twr in Game.towers:
		var twr_path = Game.towers[twr].resource_path
		$Spawners/TowerSpawner.add_spawnable_scene(twr_path)

func get_enemy_types():
	for enemy in Game.enemies:
		var enemy_path = Game.enemies[enemy].resource_path
		$Spawners/EnemySpawner.add_spawnable_scene(enemy_path)

#func get_projectile_types():
	#for p in Game.projectiles:
		#var path = Game.projectiles[p].resource_path
		#$Spawners/ProjectileSpawner.add_spawnable_scene(path)
	#for e in Game.effects:
		#var path = Game.effects[e].resource_path
		#$Spawners/ProjectileSpawner.add_spawnable_scene(path)

func _on_ui_twr_btn_pressed(scene:PackedScene) -> void:
	# Create a Tower when the Button is pressed
	if not buildmode:
		tower_type = scene.resource_path
		currently_building = scene.instantiate() as Tower
		currently_building.buildmode = true
		currently_building.canbuild = true
		currently_building.position = get_global_mouse_position()
		currently_building_node.add_child(currently_building)
		build_timer.start()

func _input(event: InputEvent) -> void:
	if buildmode:
		if event.is_action_released("cancel"):
			currently_building.queue_free()
			buildmode = false
			return
		if event.is_action_released("action") and currently_building.canbuild:
			create_tower.rpc_id(1,tower_type,currently_building.position)

@rpc("any_peer","call_local","reliable")
func create_tower(twr_type, pos:Vector2):
	if multiplayer.is_server():
		var peer_id = multiplayer.get_remote_sender_id()
		var new_tower = load(twr_type).instantiate() as Tower
		if MultiplayerManager.players[peer_id].money >= new_tower.cost:
			MultiplayerManager.players[peer_id].money -= new_tower.cost
			new_tower.position = pos
			new_tower.owner_id = peer_id
			towers.add_child(new_tower,true)
			if peer_id == 1:
				tower_result(true,new_tower.cost)
			else:
				tower_result.rpc_id(peer_id,true,new_tower.cost)
			get_towers()
			MultiplayerManager.update_ui.emit()
		else:
			if peer_id == 1:
				tower_result(false,0)
			else:
				tower_result.rpc_id(peer_id,false,0)
			

@rpc("reliable")
func tower_result(success:bool, cost:int):
	if success:
		if not multiplayer.is_server():	
			MultiplayerManager.players[id].money -= cost
		currently_building.queue_free()
		buildmode = false
		tower_type = ""
		MultiplayerManager.update_ui.emit()
	else:
		print("Can't afford!")

func create_projectile(projectile_type,pos,target,attacker,dmg):
	if multiplayer.is_server() or MultiplayerManager.multiplayer_mode == false:
		var projectile = projectile_type.instantiate() as Projectile
		if MultiplayerManager.multiplayer_mode:
			if target:
				mp_projectile.rpc(pos,projectile.proj_name,target.name)
			else:
				mp_projectile.rpc(pos,projectile.proj_name,"")
		projectile.position = pos
		projectile.target = target
		projectile.attacker = attacker
		projectile.damage = dmg
		projectiles.add_child(projectile,true)

@rpc("call_remote","reliable")
func mp_projectile(pos, projectile_name:String, target_name:String):
	var mp_proj = Game.projectiles[projectile_name].instantiate() as Projectile
	mp_proj.position = pos
	if target_name != "":
		mp_proj.target = $Enemies.get_node(target_name)
	projectiles.add_child(mp_proj,true)

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
	enemies.add_child(enemy,true)

func enemy_finished(dmg:int):
	Globals.health -= dmg

func enemy_add_effect(target:Node,attacker,effect:PackedScene):
	if multiplayer.is_server() or MultiplayerManager.multiplayer_mode == false:
		var new_effect = effect.instantiate()
		var pos = target.position
		new_effect.attacker = attacker
		if MultiplayerManager.multiplayer_mode:
			if target:
				mp_add_effect.rpc(pos,new_effect.dmg_name,target.name)
			else:
				mp_add_effect.rpc(pos,effect.dmg_name,"")
		target.add_child.call_deferred(new_effect)

@rpc("call_remote","reliable")
func mp_add_effect(pos, effect_name:String, target_name:String):
	var mp_effect = Game.effects[effect_name].instantiate() as Effect
	var target
	if target_name != "":
		target = $Enemies.get_node(target_name)
	#mp_effect.global_position = pos	
	mp_effect.target = target
	target.add_child(mp_effect,true)

func _on_build_timer_timeout() -> void:
	buildmode = true
