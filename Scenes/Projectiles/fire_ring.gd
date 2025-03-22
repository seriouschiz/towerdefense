extends Projectile

@export var duration: float
@onready var lifetime: Timer = $Lifetime

var targets = []

func _ready() -> void:
	lifetime.start(duration)

func _process(_delta: float) -> void:
	pass

func move(_delta:float):
	pass

func _on_body_entered(body: Node2D) -> void:
	targets.append(body.get_parent())

func _on_body_exited(body: Node2D) -> void:
	if "add_effect" in body.get_parent():
		body.get_parent().add_effect(Globals.effects.burning)
	targets.erase(body.get_parent())

func _on_tick_dmg_timeout() -> void:
	for enemy in targets:
		if "hit" in enemy:
			enemy.hit(damage,dmg_name,attacker)

func _on_lifetime_timeout() -> void:
	queue_free()
