extends Node

enum PREFERENCE {ALWAYS_TRUE, ALWAYS_FALSE, LIKES, HATES}
enum SOIL_TYPES {ANY, NONE, GRAVEL, DIRT}
enum GROWTH_STAGES {SEED = 0, STAGE_1 = 1, STAGE_2 = 2, STAGE_3 = 3, STAGE_4 = 4}

const PROFILE_FOLDER = "res://Plants/Profiles/"

var profiles := {}

func setup():
	var dir = Directory.new()
	dir.open(PROFILE_FOLDER)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif "tres" in file:
			var new_profile := load(PROFILE_FOLDER + file) as PlantProfile
			new_profile.setup()
			profiles[new_profile.name] = new_profile

	dir.list_dir_end()
