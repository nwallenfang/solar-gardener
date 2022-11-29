extends Spatial

func move_and_test(position_world: Vector3) -> bool:
	global_translation = position_world
	return len($Area.get_overlapping_areas()) == 0 and len($Area.get_overlapping_bodies()) == 0

func get_last_colliders():
	return $Area.get_overlapping_areas()


var reliable_test := false
func start_reliable_test(position_world: Vector3) -> bool:
	if not reliable_test:
		global_translation = position_world
		reliable_test = true
		return true
	else:
		return false

func get_reliable_result() -> bool:
	reliable_test = false
	return len($Area.get_overlapping_areas()) == 0
