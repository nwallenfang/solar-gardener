extends Spatial

func _ready() -> void:
	Game.planet = $Planet  # this is the starting planet
	Game.planet.set_primary_state(true)
	PlantData.setup()
	PlantData.add_test_progress()
