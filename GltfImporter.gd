tool
extends Node

export var gltf_folder : String
export var models_folder : String

export var prefix : String
export var suffix : String

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
	dir.open(gltf_folder)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with(".gltf"):
			files.append(file)

	dir.list_dir_end()

	for f in files:
		print("Importing " + f + " ...")
		
		var scene_name = f.split(".")[0]
		var new_file_path = models_folder + prefix + scene_name + suffix + ".tscn"
		
		var file2Check = File.new()
		var doesFileExists = file2Check.file_exists(new_file_path)
		
		var gltf_scene : Spatial = load(gltf_folder + f).instance()
		
		if not doesFileExists:
			gltf_scene.name = prefix + scene_name + suffix
			var packed_scene = PackedScene.new()
			packed_scene.pack(gltf_scene)
			ResourceSaver.save(new_file_path, packed_scene)
			print("New file " + new_file_path + " created.")
		else:
			var old_scene : Spatial = load(new_file_path).instance()
			
			for child in get_all_children(gltf_scene):
				child = child as Node
				#print("Testing: " + str(child))
				#print(gltf_scene.get_path_to(child))
				if not old_scene.has_node(gltf_scene.get_path_to(child)):
					#print("Not Found")
					var old_scene_parent : Node = old_scene.get_node(gltf_scene.get_path_to(child.get_parent()))
					#print(gltf_scene.get_path_to(child.get_parent()))
					#print("Parent: " + str(old_scene_parent))
					var copy = child.duplicate(15)
					#print("Copy: " + str(copy))
					old_scene_parent.add_child(copy)
					copy.set_owner(old_scene)
					for copy_child in get_all_children(copy):
						copy_child.set_owner(old_scene)
			
			for child in get_all_children(old_scene):
				if child is MeshInstance:
					var new_mesh_instance = gltf_scene.get_node(old_scene.get_path_to(child)) as MeshInstance
					child.mesh = new_mesh_instance.mesh
			
			var packed_scene = PackedScene.new()
			packed_scene.pack(old_scene)
			ResourceSaver.save(new_file_path, packed_scene)
			print("Old file " + new_file_path + " updated.")
		
		print("------------------------")
