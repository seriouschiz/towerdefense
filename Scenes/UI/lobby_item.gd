extends HBoxContainer

@export var player_name = "Player Name"
@export var player_id = "Player ID"

func _ready() -> void:
	$PlayerName.text = str(player_name)
	$PlayerID.text = str(player_id)
