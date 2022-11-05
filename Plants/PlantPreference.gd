extends Resource
class_name PlantPreference

export var name: String
export var description: String
export var icon: Texture


func setup():
	# TODO do I need this???
	
	var dir = Directory.new()
	dir.open(Game.MODELS_FOLDER)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break


	dir.list_dir_end()
