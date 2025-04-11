extends CanvasLayer

signal twr_btn_pressed(scene:PackedScene)
signal start_wave()

@onready var health_text = $StatsContainer/HealthHbox/HealthText
@onready var health_amount = $StatsContainer/HealthHbox/HealthAmount
@onready var money_text = $StatsContainer/MoneyHbox/MoneyText
@onready var money_amount = $StatsContainer/MoneyHbox/MoneyAmount
@onready var enemies_amount: Label = $StatsContainer/EnemiesHbox/EnemiesAmount
@onready var build_buttons_container: HBoxContainer = $BuildButtonsContainer
@onready var start_wave_button: Button = $StartWaveButton
var tower_button: PackedScene = preload("res://Scenes/UI/Buttons/tower_button.tscn")

var id:int = 0

func _ready() -> void:
	MultiplayerManager.update_ui.connect(update_all)
	update_all()
	update_buttons()
	
	if MultiplayerManager.multiplayer_mode or multiplayer.is_server() == false:
		start_wave_button.hide()

func setup_multiplayer():
	if id == 0:
		id = multiplayer.get_unique_id()
		if id != 0:
			print("Your ID is %s" % id)
		else:
			print("No ID is set: " + str(id))

func update_buttons():
	for child in build_buttons_container.get_children():
		child.queue_free()
	for tower in Game.towers:
		var twr = Game.towers[tower].instantiate()
		var button = tower_button.instantiate()
		button.icon = twr.icon
		button.scene = Game.towers[tower]
		button.text = str(twr.cost)
		button.twr_btn.connect(tower_button_pressed)
		build_buttons_container.add_child(button)
		twr.queue_free()

func tower_button_pressed(scene:PackedScene):
	#print(str("Building ",type,". Cost: $",cost,"..."))
	twr_btn_pressed.emit(scene)

func update_all():
	setup_multiplayer()
	update_health()
	update_money()
	enemies_amount.text = str(Globals.enemies_alive)
	if Globals.wave_in_progress == false:
		show_start_button()

func update_health():
	health_amount.text = str(Globals.health)
	
func update_money():
	#money_amount.text = str(Globals.money)
	if MultiplayerManager.multiplayer_mode and id:
		money_amount.text = str(MultiplayerManager.players[id].money)
		#print(str("Player ", id,": $",MultiplayerManager.players[id].money))
	else:
		money_amount.text = "No money amount set"

func _on_start_wave_button_pressed() -> void:
	start_wave.emit()
	start_wave_button.hide()

func show_start_button():
	if multiplayer.is_server() or MultiplayerManager.multiplayer_mode == false:
		start_wave_button.show()


func _on_timer_timeout() -> void:
	update_all() # TODO: Don't rely on this timer to update the UI
