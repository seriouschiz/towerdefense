class_name Projectile
extends Area2D

var target
@export var speed: int
var damage: int
var attacker # ID of the owner of the tower that fired the projectile
@export var dmg_name: String
var direction: Vector2

func _process(delta: float) -> void:
	if speed != 0 or speed != null:
		move(delta)

func move(delta: float):
	if target == null:
		#print(str(self," has no target!"))
		queue_free()
		return
	else:
		direction = (target.global_position - global_position).normalized()
		position.x += direction.x * speed * delta
		position.y += direction.y * speed * delta
		look_at(target.global_position)

func _on_body_entered(body: Node2D) -> void:
	#print(str("Hit ",body))
	if "hit" in body.get_parent() and body.get_parent() == target:
		body.get_parent().hit(damage,dmg_name,attacker)
		queue_free()
