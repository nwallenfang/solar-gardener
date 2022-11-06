extends Spatial
class_name Planet

export var planet_name : String

export var soil_type : int
export var sun : bool
export var moist : bool
export var nutrients : bool

export var max_plants : int

var plant_list := []

func add_plant(plant):
	add_child(plant)
	plant_list.append(plant)

func _ready():
	Game.planet_list.append(self)

func set_primary_state(b: bool):
	$Area.set_deferred("monitoring", not b)
	$Area.set_deferred("monitorable", not b)

func get_count_of_plant_type(plant_name: String) -> int:
	var count := 0
	for plant in plant_list:
		if plant.profile.name == plant_name:
			count += 1
	return count
