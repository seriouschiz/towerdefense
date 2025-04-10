class_name Tower
extends Area2D

signal shoot(projectile:Projectile, pos:Vector2, target: Node2D, attacker: String, dmg: int)

@export var type: String
@export var cost: int
@export var icon: Texture2D
@export var projectile_type: PackedScene
@export var attack_range: int = 250
@export var damage: int ## Damage each attack does
@export var attack_cd: float ## Time in seconds between attacks

var owner_id = 1

var target
var new_target
var target_pos
var in_range = []
var can_attack:bool = true

var canbuild: bool = false
var range_color: Color = Color.TRANSPARENT
var range_good: Color = Color.hex(0x00e5003e)
var range_bad: Color = Color.hex(0xe6080048)
var overlapping = []

@export var buildmode: bool = true ## Whether or not the tower is being built

@onready var target_refresh: Timer = $Timers/TargetRefresh
@onready var attack_cooldown: Timer = $Timers/AttackCooldown
@onready var wake: Timer = $Timers/Wake
@onready var fire_point: Marker2D = $Top/FirePoint
@onready var state_changer: AnimationPlayer = $StateChanger
@onready var top: Sprite2D = $Top
@onready var attackrangearea: Area2D = $AttackRange

func _ready() -> void:
	$AttackRange/CollisionShape2D.shape.radius = attack_range
	attack_cooldown.wait_time = attack_cd
	if MultiplayerManager.multiplayer_mode:
		if buildmode:
			$MultiplayerSynchronizer.public_visibility = false
		else:
			$MultiplayerSynchronizer.public_visibility = true

func _draw() -> void:
	draw_circle(Vector2.ZERO,attack_range,range_color)
	pass

func _process(_delta: float) -> void:
	if buildmode:
		position = get_global_mouse_position()
		if canbuild and Globals.money >= cost:
			range_color = range_good
			state_changer.play("buildmode_good")
		else:
			range_color = range_bad
			state_changer.play("buildmode_bad")
	else:
		if multiplayer.is_server() or MultiplayerManager.multiplayer_mode == false:
			if target != null:
				target_pos = target.global_position
		if target_pos != null:
			top.look_at(target_pos)

func _on_attack_range_body_entered(body: Node2D) -> void:
	if multiplayer.is_server() or MultiplayerManager.multiplayer_mode == false:
		#print(str(get_parent()," has entered"))
		in_range.append(body.get_parent())
		#print(body.get_parent().path_progress)
		#print(str("Targets: ",in_range))
		if attack_cooldown.is_stopped():
			#attack_cooldown.start()
			wake.start()

func _on_attack_range_body_exited(body: Node2D) -> void:
	if multiplayer.is_server() or MultiplayerManager.multiplayer_mode == false:
		#print(str(body.get_parent()," has exited"))
		in_range.erase(body.get_parent())
		if in_range.is_empty():
			target = null
			target_pos = null

func get_target():
	if multiplayer.is_server() == false and MultiplayerManager.multiplayer_mode:
		return
	if not in_range.is_empty():
		for enemy in in_range:
			if "path_progress" in enemy:
				if new_target == null:
					new_target = enemy
					#print(new_target)
					#print(new_target.path_progress)
				if enemy.path_progress > new_target.path_progress:
					new_target = enemy
		target = new_target

func _on_target_refresh_timeout() -> void:
	if multiplayer.is_server() == false and MultiplayerManager.multiplayer_mode:
		return
	if buildmode:
		attackrangearea.monitoring = false
	else:
		if multiplayer.is_server() or MultiplayerManager.multiplayer_mode == false:
			attackrangearea.monitoring = true
			get_target()

func _on_attack_cooldown_timeout() -> void:
	if multiplayer.is_server() == false and MultiplayerManager.multiplayer_mode:
		return
	if not in_range.is_empty():
		shoot.emit(projectile_type, fire_point.global_position,target,self.name,damage)
	else:
		attack_cooldown.stop()

func _on_wake_timeout() -> void:
	if multiplayer.is_server() == false and MultiplayerManager.multiplayer_mode:
		return
	shoot.emit(projectile_type, fire_point.global_position,target,self.name,damage)
	attack_cooldown.one_shot = false
	attack_cooldown.start()

# If tower is overlapping with anything, cannot build
func _on_area_entered(area: Area2D) -> void:
	canbuild = false
	overlapping.append(area)

func _on_area_exited(area: Area2D) -> void:
	overlapping.erase(area)
	if overlapping.is_empty():
		canbuild = true
