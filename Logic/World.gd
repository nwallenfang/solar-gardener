extends Spatial

func _ready() -> void:
	Game.planet = $Planet  # this is the starting planet
	PlantData.setup()
	PlantData.add_test_progress()
