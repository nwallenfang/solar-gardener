extends Resource
class_name PlantProfile

export var name: String
export var fluff_base: String
export var fluff_stage2: String
export var fluff_stage3: String
export var icon: Texture

export var sun: int
export var moisture: int
export var nutrients: int

export var group: int

export var prefered_soil: int

export var seed_count: int

var points_for_stage_1: int
var points_for_stage_2: int
var points_for_stage_3: int
var points_for_stage_4: int

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
