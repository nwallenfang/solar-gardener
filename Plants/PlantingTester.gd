extends Spatial

func move_and_test(position_world: Vector3) -> bool:
	global_translation = position_world
	$Area.force_update_transform()
	return len($Area.get_overlapping_areas()) == 0

func get_last_colliders():
	return $Area.get_overlapping_areas()
