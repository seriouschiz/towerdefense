class_name Enemy
extends PathFollow2D

signal effect_added(target:Node,effect:PackedScene)
signal finished

@export var speed: int
@export var maxhealth: float
var health: float
@export var value: int
@export var damage: int = 1
@export var path_progress: float
@onready var healthbar: ProgressBar = $PanelContainer/HealthBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = maxhealth
	healthbar.max_value = maxhealth
	healthbar.value = health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress += speed * delta
	path_progress = progress_ratio
	if progress_ratio >= 1:
		finished.emit(damage)
		Globals.enemies_alive -= 1
		queue_free()

func hit(dmg:int,_source:String,_attacker:String):
	health -= dmg
	healthbar.value = health
	# print(str(self," was hit by ",source," from ",attacker," for ",damage," damage! Health: ",health))
	if health <= 0:
		die()

func add_effect(effect:PackedScene):
	effect_added.emit(self,effect)

func die():
	Globals.money += value
	Globals.enemies_alive -= 1
	queue_free()
