extends Spatial

var analyse_name := "Mechanical Object"

func get_analyse_text():
	return "New Yardintool\nUpgrade unlocked"

var death := false
func on_analyse():
	if death:
		return
	death = true
	Upgrades.gear_count += 1
	Events.trigger("gear_scanned")
	print("You now have " + str(Upgrades.gear_count) + " gears")
	$DeathPlayer.play("death")
	yield($DeathPlayer,"animation_finished")
	queue_free()
