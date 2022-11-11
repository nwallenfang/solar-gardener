extends Spatial

export var SKY_ENERGY_HTML5 := 0.04
export var SKY_ENERGY_NATIVE := 0.5

func _ready() -> void:
	if OS.has_feature("HTML5"):
		$WorldEnvironment.environment.background_energy = SKY_ENERGY_HTML5
	else:
		$WorldEnvironment.environment.background_energy = SKY_ENERGY_NATIVE
	

	Game.planet = $Planet  # this is the starting planet
	Game.planet.set_player_is_on_planet(true)
	PlantData.setup()
	PlantData.add_test_progress()
	Game.sun = $Sun
	for c in get_children():
		if c is Planet:
			(c as Planet).setup()
			
	yield(get_tree().create_timer(1.0), "timeout")
	Events.tutorial_beginning()
