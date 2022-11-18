extends Resource
class_name PlantProfile

enum PREFERENCE {ALWAYS_TRUE, ALWAYS_FALSE, LIKES, HATES}
enum SOIL_TYPES {ANY, NONE, ROCK, DIRT, SAND}
enum GROWTH_STAGES {SEED = 0, STAGE_1 = 1, STAGE_2 = 2, STAGE_3 = 3, STAGE_4 = 4}
enum PLANT_TYPES {NONE, THORNY, SHROOM, FLOWER}

export var name: String
export var mesh_file_name: String

export(PLANT_TYPES) var plant_type: int

export(String, MULTILINE) var fluff_base: String
export(String, MULTILINE) var fluff_stage2: String
export(String, MULTILINE) var fluff_stage3: String
export var icon: Texture

export(PREFERENCE) var sun: int
export(PREFERENCE) var moisture: int
export(PREFERENCE) var nutrients: int

export(PREFERENCE) var group: int

export(SOIL_TYPES) var prefered_soil: int

export var seed_count: int

export var points_for_stage_1: int
export var points_for_stage_2: int
export var points_for_stage_3: int
export var points_for_stage_4: int

var model_seed: PackedScene
var model_stage_1: PackedScene
var model_stage_2: PackedScene
var model_stage_3: PackedScene
var model_stage_4: PackedScene

const MODEL_SEED_PLACEHOLDER = preload("res://Assets/Placeholder/ModelPlaceholderSeed.tscn")
const MODEL_STAGE_1_PLACEHOLDER = preload("res://Assets/Placeholder/ModelPlaceholderStage1.tscn")
const MODEL_STAGE_2_PLACEHOLDER = preload("res://Assets/Placeholder/ModelPlaceholderStage2.tscn")
const MODEL_STAGE_3_PLACEHOLDER = preload("res://Assets/Placeholder/ModelPlaceholderStage3.tscn")
const MODEL_STAGE_4_PLACEHOLDER = preload("res://Assets/Placeholder/ModelPlaceholderStage4.tscn")

func setup():
	model_seed = MODEL_SEED_PLACEHOLDER
	model_stage_1 = MODEL_STAGE_1_PLACEHOLDER
	model_stage_2 = MODEL_STAGE_2_PLACEHOLDER
	model_stage_3 = MODEL_STAGE_3_PLACEHOLDER
	model_stage_4 = MODEL_STAGE_4_PLACEHOLDER
	
	var dir = Directory.new()
	dir.open(Game.MODELS_FOLDER)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif name in file:
			if "Seed" in file:
				model_seed = load(Game.MODELS_FOLDER + file)
			elif "Stage1" in file:
				model_stage_1 = load(Game.MODELS_FOLDER + file)
			elif "Stage2" in file:
				model_stage_2 = load(Game.MODELS_FOLDER + file)
			elif "Stage3" in file:
				model_stage_3 = load(Game.MODELS_FOLDER + file)
			elif "Stage4" in file:
				model_stage_4 = load(Game.MODELS_FOLDER + file)

	dir.list_dir_end()
