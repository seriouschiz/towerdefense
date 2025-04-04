extends CharacterBody2D

@export var speed: int = 400
@onready var camera: Camera2D = $Camera2D

var player_name: String
var player_id := 1:
	set(id):
		player_id=id
		$InputSynchronizer.set_multiplayer_authority(id)

func _ready() -> void:
	multiplayer.connected_to_server.connect(_set_up_mp_authority)

func _set_up_mp_authority():
	print("Connected to server")
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	print(str(name," id = ",player_id))
	Globals.multiplayer_id = player_id
	print(str("MP ID: ", Globals.multiplayer_id))
	player_name = Globals.player_name

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
