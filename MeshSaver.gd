tool
extends Node


export var models_folder : String
export var mesh_folder : String
export var collision_folder: String

#export var prefix : String
#export var suffix : String

export var do_import := false setget _do_import

func get_all_children(node: Node):
	var list := []
	for c in node.get_children():
		list.append(c)
		list.append_array(get_all_children(c))
	return list

func _do_import(useless_parameter):
	if not useless_parameter:
		return
	var files = []
	var dir = Directory.new()
	dir.open(models_folder)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with(".tscn"):
			files.append(file)
	
	dir.list_dir_end()
	print("DO MESH SAVER")
	for f in files:
		print("Importing " + f + " ...")
		var scene_name = f.split(".")[0]	
		var model_scene = load(models_folder + f).instance()
	
		# go over every node in the model scene
		# check each MeshInstance
		# if it has arraymesh, save it as scn in mesh_folder
		for child in get_all_children(model_scene):
			if child is MeshInstance:
				child = child as MeshInstance
				if child.mesh == null:
					continue
				var path: String = child.mesh.resource_path
				var new_path 
				if len(path.split(".tscn")) > 1:
					var array_mesh: Resource = child.mesh
					var mesh_no = path.split("::")[1]
					var filename: String = "Mesh" + scene_name.split("Model")[1] + mesh_no + ".res"
					new_path = mesh_folder + filename
					print("saving to " + new_path)

					var err = ResourceSaver.save(new_path, array_mesh, ResourceSaver.FLAG_CHANGE_PATH & ResourceSaver.FLAG_COMPRESS)
					if err != 0:
						printerr("Error code " + err)
					
					array_mesh.take_over_path(new_path)
				else:
					print("mesh is saved externally already (good)")
			if child is CollisionShape:  # these are worth saving as well
				child = child as CollisionShape
				if not child.shape is ConcavePolygonShape:
					continue  # only worth saving these
				var shape: ConcavePolygonShape = child.shape
				var path: String = shape.resource_path
				var new_path 
				if len(path.split(".tscn")) > 1:
					var res_no = path.split("::")[1]
					var filename: String = "Shape" + scene_name.split("Model")[1] + res_no + ".res"
					new_path = collision_folder + filename
					print("saving to " + new_path)

					var err = ResourceSaver.save(new_path, shape, ResourceSaver.FLAG_CHANGE_PATH & ResourceSaver.FLAG_COMPRESS)
					if err != 0:
						printerr("Error code " + err)
					
					shape.take_over_path(new_path)
				else:
					print("done already")

		var new_scene := PackedScene.new()
		new_scene.pack(model_scene)

		var err = ResourceSaver.save(models_folder + f, new_scene)
		if err != 0:
			printerr("Scene save Error code " + err)
		print("------------------------")

#		var file2Check = File.new()
#		var doesFileExists = file2Check.file_exists(new_file_path)
#
#		var gltf_scene : Spatial = load(gltf_folder + f).instance()
#
#		if not doesFileExists:
#			gltf_scene.name = prefix + scene_name + suffix
#			var packed_scene = PackedScene.new()
#			packed_scene.pack(gltf_scene)
#			ResourceSaver.save(new_file_path, packed_scene)
#			print("New file " + new_file_path + " created.")
#		else:
#			var old_scene : Spatial = load(new_file_path).instance()
#
#			for child in get_all_children(gltf_scene):
#				child = child as Node
#				#print("Testing: " + str(child))
#				#print(gltf_scene.get_path_to(child))
#				if not old_scene.has_node(gltf_scene.get_path_to(child)):
#					#print("Not Found")
#					var old_scene_parent : Node = old_scene.get_node(gltf_scene.get_path_to(child.get_parent()))
#					#print(gltf_scene.get_path_to(child.get_parent()))
#					#print("Parent: " + str(old_scene_parent))
#					var copy = child.duplicate(15)
#					#print("Copy: " + str(copy))
#					old_scene_parent.add_child(copy)
#					copy.set_owner(old_scene)
#					for copy_child in get_all_children(copy):
#						copy_child.set_owner(old_scene)
#
#			for child in get_all_children(old_scene):
#				if child is MeshInstance:
#					if gltf_scene.has_node(old_scene.get_path_to(child)):
#						var new_mesh_instance = gltf_scene.get_node(old_scene.get_path_to(child)) as MeshInstance
#						child.mesh = new_mesh_instance.mesh
#
#			var packed_scene = PackedScene.new()
#			packed_scene.pack(old_scene)
