class_name Enemy
extends PathFollow2D

signal effect_added(target:Node,attacker,effect:PackedScene)
signal finished

var health: float:
	set(value):
		health = value
		update_healthbar()

@export var speed: int
@export var maxhealth: float
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

func hit(dmg:int,_source:String,attacker):
	if not multiplayer.is_server():
		return
	health -= dmg
	# print(str(self," was hit by ",source," from ",attacker," for ",damage," damage! Health: ",health))
	if health <= 0:
		die(attacker)

func update_healthbar():
	if healthbar:
		healthbar.value = health

func add_effect(attacker,effect:PackedScene):
	effect_added.emit(self,attacker,effect)

func die(attacker_id):
	if multiplayer.is_server() or MultiplayerManager.multiplayer_mode == false:
		give_money(attacker_id)
		Globals.enemies_alive -= 1
		update_client_ui.rpc()
	queue_free()

func give_money(attacker_id):
	for plr in MultiplayerManager.players:
		if plr == attacker_id:
			MultiplayerManager.players[attacker_id].money += value
			print(str("Giving player ",attacker_id," $",value))
		else:
			MultiplayerManager.players[plr].money += (value/2)
			print(str("Giving player ",plr," $",(value/2)))

@rpc("call_remote","reliable")
func update_client_ui():
	MultiplayerManager.update_ui.emit()
