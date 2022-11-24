extends Node

#enum PREFERENCE_TYPES {SOIL, SUN, MOISTURE, NUTRIENTS, GROUP}
#icons: positiv: GRAVEL, DIRT, SAND, LIKES, HATES
enum PREFERENCE {ALWAYS_TRUE, ALWAYS_FALSE, LIKES, HATES}
enum SOIL_TYPES {ANY, NONE, ROCK, DIRT, SAND}
enum GROWTH_STAGES {SEED = 0, STAGE_1 = 1, STAGE_2 = 2, STAGE_3 = 3, STAGE_4 = 4}
enum PLANT_TYPES {NONE, THORNY, SHROOM, FLOWER}

const PROFILE_FOLDER = "res://Plants/Profiles/"
const PREFERENCE_FOLDER = "res://Plants/Preferences/"
const PREFERENCES = {}


var profiles := {}

onready var progress := {

}

var seed_counts := {
	
}

var plants_initiated_done = false
signal plants_initiated

func add_test_progress():
#	progress["Seedling"] = [
#		PREFERENCES["Likes Water"]
#	]
	pass

#signal new_progress(plant_name, preference)
func add_preference_progress(plant_name: String, progress_type: String):
	# "pflanze1", "watering"
	# look if this is new progress
	if not plant_name in progress:
		progress[plant_name] = []
		
	progress[plant_name].append(PREFERENCES[progress_type])
	# TODO where to check if this plant even has this type of progress!?
#	emit_signal(plant_name, PREFERENCES[progress_type])
	if Game.UI != null:
		Game.UI.get_node("JournalAndGuideUI/JournalUI").new_progress(plant_name, PREFERENCES[progress_type])

func add_stage_progress(plant_name, growth_stage):
	pass
	
func plant_profile_to_preference_list(plant: PlantProfile) -> Array:
	var preference_list = []
	if plant.sun == PREFERENCE.LIKES:
		preference_list.append(PREFERENCES["Likes Sun"])
	if plant.sun == PREFERENCE.HATES:
		preference_list.append(PREFERENCES["Hates Sun"])
	if plant.moisture == PREFERENCE.LIKES:
		preference_list.append(PREFERENCES["Likes Water"])
	if plant.moisture == PREFERENCE.HATES:
		preference_list.append(PREFERENCES["Hates Water"])
	if plant.nutrients == PREFERENCE.LIKES:
		preference_list.append(PREFERENCES["Likes Nutrients"])
	if plant.nutrients == PREFERENCE.HATES:
		preference_list.append(PREFERENCES["Hates Nutrients"])
	if plant.group == PREFERENCE.LIKES:
		preference_list.append(PREFERENCES["Likes Groups"])
	if plant.group == PREFERENCE.HATES:
		preference_list.append(PREFERENCES["Hates Groups"])
	if plant.prefered_soil == SOIL_TYPES.DIRT:
		preference_list.append(PREFERENCES["Likes dirt planets"])
	if plant.prefered_soil == SOIL_TYPES.ROCK:
		preference_list.append(PREFERENCES["Likes rocky planets"])
	if plant.prefered_soil == SOIL_TYPES.SAND:
		preference_list.append(PREFERENCES["Likes sandy planets"])
	if plant.symbiosis_plant_type == PLANT_TYPES.FLOWER:
		preference_list.append(PREFERENCES["Likes Flowers"])
	if plant.symbiosis_plant_type == PLANT_TYPES.SHROOM:
		preference_list.append(PREFERENCES["Likes Shrooms"])
	if plant.symbiosis_plant_type == PLANT_TYPES.THORNY:
		preference_list.append(PREFERENCES["Likes Thornys"])

	return preference_list


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
			seed_counts[new_profile.name] = 0

	dir.list_dir_end()

	dir = Directory.new()
	dir.open(PREFERENCE_FOLDER)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif "tres" in file:
			var new_preferences := load(PREFERENCE_FOLDER + file) as PlantPreference
			PREFERENCES[new_preferences.name] = new_preferences

	dir.list_dir_end()
	
	emit_signal("plants_initiated")
	plants_initiated_done = true


func can_plant(plant_name):
	return seed_counts[plant_name] > 0

func plant(plant_name):
	seed_counts[plant_name] -= 1
	emit_signal("seeds_updated", plant_name, seed_counts[plant_name])


signal seeds_updated(plant_name, seed_total)  # -> JournalUI is listening
signal got_seeds(plant_name, seed_amount)
func give_seeds(plant_name: String, seed_amount:int) -> void:
	seed_counts[plant_name] += seed_amount
	Audio.play("ui2")
	emit_signal("seeds_updated", plant_name, seed_counts[plant_name])
	emit_signal("got_seeds", plant_name, seed_amount)
	

signal growth_stage_reached(plant_name, growth_stage) # -> JournalUI is listening
func growth_stage_reached(plant_name, growth_stage):
	# this is what peak godot code looks like :)
	emit_signal("growth_stage_reached", plant_name, growth_stage)
