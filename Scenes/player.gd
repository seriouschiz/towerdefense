extends CharacterBody2D

@export var speed: int = 400
@onready var camera: Camera2D = $Camera2D

var player_name: String
var player_id := 1:
	set(id):
		player_id=id

func get_input():
	var input_direction = Input.get_vector("MoveLeft","MoveRight","MoveUp","MoveDown")
	velocity = input_direction * speed

func _physics_process(_delta: float) -> void:
	get_input()
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ZoomIn"):
		camera.zoom += Vector2(.05,.05)
	if event.is_action_pressed("ZoomOut"):
		camera.zoom -= Vector2(.05,.05)
