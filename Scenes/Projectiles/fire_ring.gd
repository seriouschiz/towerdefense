extends Projectile

@export var duration: float
@onready var lifetime: Timer = $Lifetime

var proj_name = "fire_ring"

var targets = []

func _ready() -> void:
	lifetime.start(duration)

func _process(_delta: float) -> void: #DON'T REMOVE, OVERRIDING DEFAULT BEHAVIOR
	pass

func move(_delta:float): #DON'T REMOVE, OVERRIDING DEFAULT BEHAVIOR
	pass

func _on_body_entered(body: Node2D) -> void:
	if multiplayer.is_server() or MultiplayerManager.multiplayer_mode == false:
		targets.append(body.get_parent())

func _on_body_exited(body: Node2D) -> void:
	if multiplayer.is_server() or MultiplayerManager.multiplayer_mode == false:
		if "add_effect" in body.get_parent():
			body.get_parent().add_effect(attacker,Game.effects.burning)
		targets.erase(body.get_parent())

func _on_tick_dmg_timeout() -> void:
	if multiplayer.is_server() or MultiplayerManager.multiplayer_mode == false:
		for enemy in targets:
			if "hit" in enemy:
				enemy.hit(damage,dmg_name,attacker)

func _on_lifetime_timeout() -> void:
	queue_free()
