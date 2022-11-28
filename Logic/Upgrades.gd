extends Node

var gear_count := 0
var current_upgrade_level := 0

func is_upgrade_available() -> bool:
	return gear_count > current_upgrade_level

func ugrade_once():
	current_upgrade_level += 1
	print("Upgraded to level " + str(current_upgrade_level))
	match current_upgrade_level:
		1: # Hopper
			Events.trigger("tutorial_completed")
		2: # Soil
			Events.trigger("soil_unlocked")
		3: # Remove
			Events.trigger("remove_unlocked")
		4: # Jetpack
			pass
		5: # Flashlight
			pass

func get_upgrades_screen_text() -> String:
	var new_upgrades_count = gear_count - current_upgrade_level
	if new_upgrades_count == 0:
		return "Find more\ngears to\nunlock new\nupgrades"
	elif new_upgrades_count == 1:
		return "1 new\nupgrade\navailable"
	else:
		return str(new_upgrades_count) + " new\nupgrades\navailable"
