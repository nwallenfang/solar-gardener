extends Node

func get_all_mesh_instance_children(mother_node: Spatial) -> Array:
	var list := []
	if mother_node is Node:
		for c in mother_node.get_children():
			if c is MeshInstance:
				list.append(c)
			list.append_array(get_all_mesh_instance_children(c))
	return list

func test_planting_position(pos: Vector3) -> bool:
	return $PlantingTester.move_and_test(pos)

func get_last_planting_test_collider_areas() -> Array:
	return $PlantingTester.get_last_colliders()


func start_reliable_test(position_world: Vector3) -> bool:
	return $ReliablePlantingTester.start_reliable_test(position_world)

func get_reliable_result() -> bool:
	return $ReliablePlantingTester.get_reliable_result()


func get_basis_y_aligned(target_up: Vector3) -> Basis:
	var basis := Basis.IDENTITY
	basis = basis.rotated(Vector3.UP.cross(target_up).normalized(), Vector3.UP.angle_to(target_up))
	basis = basis.rotated(target_up.normalized(), randf() * PI * 2.0)
	return basis

func get_basis_y_aligned_with_z(target_up: Vector3, old_look: Vector3) -> Basis:
	var basis := Basis.IDENTITY
	basis = basis.rotated(Vector3.UP.cross(target_up).normalized(), Vector3.UP.angle_to(target_up))
	var target_look := old_look.cross(-target_up).cross(target_up)
	return Basis(-target_up.cross(target_look), target_up, -target_look).orthonormalized()

# Function for getting the weights for lerping with more than 2 objects (usefull for things like transformas)
func get_multi_lerp_weights(distribution: Array) -> Array:
	var weights := []
	var current_sum : float = distribution[0]
	for i in range(1, len(distribution)):
		var new_element : float = distribution[i]
		current_sum += new_element
		weights.append(new_element / current_sum)
	return weights

func get_planet_surface_point_from_pos(planet:Planet, pos:Vector3) -> Vector3:
	$RayCast.global_translation = pos
	$RayCast.cast_to = $RayCast.to_local(planet.global_translation)
	$RayCast.force_raycast_update()
	return $RayCast.get_collision_point()
