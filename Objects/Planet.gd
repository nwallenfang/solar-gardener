extends Spatial
class_name Planet

export var planet_name : String
onready var analyse_name : String = planet_name
var analyse_speed_factor := .3

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
	$PlanetHopArea.set_deferred("monitoring", not b)
	$PlanetHopArea.set_deferred("monitorable", not b)
	$PlanetHopArea/CollisionShape.disabled = b

func get_count_of_plant_type(plant_name: String) -> int:
	var count := 0
	for plant in plant_list:
		if plant.profile.name == plant_name:
			count += 1
	return count
