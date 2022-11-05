extends Spatial
class_name Plant

const DEFAULT_GROW_SPEED = 1.0/20.0
const BOOSTED_GROW_SPEED = 1.0/3.0
const DEFAULT_MODEL_SCALE = 1.0
const GROWTH_UP_SCALE_FACTOR = 1.5
const GROWTH_DOWN_SCALE_FACTOR = .7

var profile: PlantProfile

var growth_stage: int = PlantData.GROWTH_STAGES.SEED
var growth_lock: int = PlantData.GROWTH_STAGES.SEED
var growth_stage_progress: float = 0.0

var planet: Spatial

var model_seed: Spatial
var model_stage_1: Spatial
var model_stage_2: Spatial
var model_stage_3: Spatial
var model_stage_4: Spatial

var model_array: Array
var current_model: Spatial

var is_setup := false
func setup():
	model_seed = profile.model_seed.instance()
	model_stage_1 = profile.model_stage_1.instance()
	model_stage_2 = profile.model_stage_2.instance()
	model_stage_3 = profile.model_stage_3.instance()
	model_stage_4 = profile.model_stage_4.instance()
	model_array = [model_seed, model_stage_1, model_stage_2, model_stage_3, model_stage_4]
	for model in model_array:
		model.visible = false
		add_child(model)
	current_model = model_seed
	current_model.visible = true
	is_setup = true

func _physics_process(delta):
	growth_process(delta)

func growth_process(delta):
	if growth_stage == growth_lock:
		check_conditions()
	if growth_stage != growth_lock and $GrowthCooldown.time_left == 0.0:
		grow(delta, sign(growth_lock - growth_stage))

func check_conditions():
	growth_lock = PlantData.GROWTH_STAGES.STAGE_4

var growth_boost := false
func grow(delta, factor_sign):
	if growth_boost:
		growth_stage_progress += BOOSTED_GROW_SPEED * delta * factor_sign
	else:
		growth_stage_progress += DEFAULT_GROW_SPEED * delta * factor_sign
	growth_boost = false
	update_growth_visuals()
	if abs(growth_stage_progress) >= 1.0:
		$GrowthCooldown.start()
		var old_stage := growth_stage
		growth_stage = growth_stage + int(factor_sign * 1.1) # "* 1.1" to avoid float error nonsense
		current_model = model_array[growth_stage]
		play_growth_pop_animation(old_stage)
		
func play_growth_pop_animation(old_stage):
	model_array[old_stage].visible = false
	model_array[old_stage].scale = Vector3.ONE * DEFAULT_MODEL_SCALE
	current_model.visible = true
	# TODO Animation

func update_growth_visuals():
	var scale_vector := Vector3.ONE
	if growth_stage_progress <= 0.0:
		scale_vector *= lerp(DEFAULT_MODEL_SCALE, GROWTH_DOWN_SCALE_FACTOR, -growth_stage_progress)
	else:
		scale_vector *= lerp(DEFAULT_MODEL_SCALE, GROWTH_UP_SCALE_FACTOR, growth_stage_progress)
	current_model.scale = scale_vector
