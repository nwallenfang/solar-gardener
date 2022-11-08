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

onready var planet_light := $PlanetLight

var plant_list := []

func add_plant(plant):
	add_child_with_light(plant)
	plant_list.append(plant)

func configure_light(n: Node):
	for mi in Utility.get_all_mesh_instance_children(n):
		(mi as MeshInstance).layers = planet_light.mask_value

func add_child_with_light(n: Node):
	add_child(n)
	configure_light(n)

func setup():
	var planet_id = Game.planet_list.size()
	Game.planet_list.append(self)
	planet_light.setup(planet_id)
	configure_light(self)

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
