extends Effect

var burn_dmg: int = 2

func _tick_effect():
	if "hit" in target:
		target.hit(burn_dmg,dmg_name,attacker)
