extends Node

func get_all_mesh_instance_children(mother_node: Spatial) -> Array:
	var list := []
	for c in mother_node.get_children():
		if c is MeshInstance:
			list.append(c)
		list.append_array(get_all_mesh_instance_children(c))
	return list
