extends Path2D

@onready var spawnpoint = curve.get_point_position(0)
signal spawn_enemy(type:PackedScene)
signal wave_complete
var current_wave:int = 0

var waves = [ # ARGUMENTS: PackedScene for enemy type, amount of enemies to spawn, time between spawns
	[ # WAVE 1
		make_wave(Game.enemies.blue_slime,3,2.0),
		make_wave(Game.enemies.blue_slime,1,4.0),
		make_wave(Game.enemies.blue_slime,2,1.0),
	],
	[ # WAVE 2
		make_wave(Game.enemies.red_slime,4,2.5),
		make_wave(Game.enemies.blue_slime,1,4.0),
		make_wave(Game.enemies.blue_slime,2,0.8),
		make_wave(Game.enemies.red_slime,2,0.8),
	],
	[ # WAVE 3
		make_wave(Game.enemies.red_slime,7,1.5),
		make_wave(Game.enemies.red_slime,1,5.0),
		make_wave(Game.enemies.blue_slime,10,0.6),
		make_wave(Game.enemies.red_slime,2,0.8),
	],
]

func make_wave(enemy:PackedScene,howmany:int,time_between_spawns:float) -> Wave:
	var new_wave = Wave.new()
	new_wave.enemy = enemy
	new_wave.howmany = howmany
	new_wave.time_between_spawns = time_between_spawns
	return new_wave

func spawn_wave():
	print(str("Spawning wave number ",(current_wave + 1),"..."))
	for enemies in waves[current_wave]:
		Globals.enemies_alive += enemies.howmany
	for enemies in waves[current_wave]:
		for enemy in enemies.howmany:
			spawn_enemy.emit(enemies.enemy)
			await get_tree().create_timer(enemies.time_between_spawns).timeout
	print(str("Wave number "),(current_wave + 1)," finished spawning.")
	current_wave += 1
	wave_complete.emit()
