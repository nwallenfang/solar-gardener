extends Node

func get_all_mesh_instance_children(mother_node: Spatial) -> Array:
	var list := []
	for c in mother_node.get_children():
		if c is MeshInstance:
			list.append(c)
		list.append_array(get_all_mesh_instance_children(c))
	return list

func test_planting_position(pos: Vector3) -> bool:
	return $PlantingTester.move_and_test(pos)

func get_basis_y_alligned(target_up: Vector3) -> Basis:
	var basis := Basis.IDENTITY
	basis = basis.rotated(Vector3.UP.cross(target_up).normalized(), Vector3.UP.angle_to(target_up))
	basis = basis.rotated(target_up, randf() * PI * 2.0)
	return basis
