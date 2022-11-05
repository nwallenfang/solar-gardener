extends Spatial
class_name Planet

var plant_list := []

func add_plant(plant):
	add_child(plant)
	plant_list.append(plant)
