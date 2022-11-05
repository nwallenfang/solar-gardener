extends Spatial

enum TOOL {NONE, PLANT, GROW, MOVE, ANALYSIS, BUILD}
var current_tool := 0

# Preloads
const FAKE_SEED = preload("res://Plants/FakeSeed.tscn")
const PLANT = preload("res://Plants/Plant.tscn")

# Plant Tool Variables
var target_plant_name := "test"
var selected_profile : PlantProfile
var seeds_empty := false
var can_plant := false
var plant_spawn_position := Vector3.ZERO
var fake_seed : Spatial

# Grow Tool Variables
const GROW_TOOL_DISTANCE = 15.0
var can_grow := false
var plant_to_grow: Plant

# Analysis Variable
const ANALYSE_TOOL_DISTANCE = 10.0
const ANALYSE_SPEED = 1.0/2.0
var can_analyse := false
var currently_analysing := false
var object_to_analyse: Spatial
var current_analyse_object: Spatial
var current_analyse_progress := 0.0


var first_action_holded := false
func _physics_process(delta):
	if Game.game_state == Game.State.INGAME:
		if $Cooldown.time_left == 0.0:
			check_on_hover()
			if Input.is_action_just_pressed("tool1"):
				switch_to_tool(TOOL.PLANT)
			if Input.is_action_just_pressed("tool2"):
				switch_to_tool(TOOL.GROW)
			if Input.is_action_just_pressed("tool3"):
				switch_to_tool(TOOL.ANALYSIS)
			if Input.is_action_just_pressed("tool4"):
				switch_to_tool(TOOL.BUILD)
			if Input.is_action_just_pressed("first_action"):
				process_first_action()
			first_action_holded = Input.is_action_pressed("first_action")
			if Input.is_action_just_pressed("second_action"):
				process_first_action()
			idle_process(delta)

# Collision masks
# 0 - Collision
# 1 - Gravity
# 2 - Analysis
# 3 - Bad Planting
# 4 - Moveable

func switch_away_from_tool(old_tool: int):
	match old_tool:
		TOOL.GROW:
			Game.player_raycast.set_collision_mask_bit(5, false)
			$Model/Grow.visible = false
		TOOL.PLANT:
			Game.player_raycast.set_collision_mask_bit(0, false)
			if is_instance_valid(fake_seed):
				fake_seed.queue_free()
		TOOL.MOVE:
			Game.player_raycast.set_collision_mask_bit(4, false)
		TOOL.ANALYSIS:
			Game.player_raycast.set_collision_mask_bit(2, false)
			$Model/Analysis.visible = false

func switch_to_tool(new_tool: int):
	if new_tool == current_tool:
		return
	switch_away_from_tool(current_tool)
	current_tool = new_tool
	
	match current_tool:
		TOOL.PLANT:
			Game.player_raycast.set_collision_mask_bit(0, true)
			selected_profile = PlantData.profiles[target_plant_name]
			if not seeds_empty:
				fake_seed = FAKE_SEED.instance()
				$SeedPosition.add_child(fake_seed)
				var seed_model = selected_profile.model_seed.instance()
				fake_seed.add_child(seed_model)
		TOOL.MOVE:
			Game.player_raycast.set_collision_mask_bit(4, true)
		TOOL.ANALYSIS:
			Game.player_raycast.set_collision_mask_bit(2, true)
			$Model/Analysis.visible = true
		TOOL.GROW:
			Game.player_raycast.set_collision_mask_bit(5, true)
			$Model/Grow.visible = true

func idle_process(delta: float):
	match current_tool:
		TOOL.GROW:
			if first_action_holded and can_grow:
				plant_to_grow.growth_boost = true
		TOOL.ANALYSIS:
			if not currently_analysing:
				if can_analyse and first_action_holded:
					currently_analysing = true
					current_analyse_object = object_to_analyse
					current_analyse_progress = 0.0
			if currently_analysing:
				if (not first_action_holded) or object_to_analyse != current_analyse_object or (not can_analyse):
					currently_analysing = false
				else:
					current_analyse_progress += ANALYSE_SPEED * delta
					if current_analyse_progress >= 1.0:
						currently_analysing = false
						$Cooldown.start(2)
						print("Analysis Done of " + str(current_analyse_object))
						if current_analyse_object.has_method("on_analyse"):
							current_analyse_object.call("on_analyse")
			show_analyse_information()

func process_first_action():
	match current_tool:
		TOOL.PLANT:
			if can_plant:
				start_planting_animation(plant_spawn_position)

func process_second_action():
	pass

func check_on_hover():
	Game.player_raycast.do_cast()
	match current_tool:
		TOOL.PLANT:
			if Game.player_raycast.colliding:
				can_plant = Utility.test_planting_position(Game.player_raycast.hit_point)
			else:
				can_plant = false
			plant_spawn_position = Game.player_raycast.hit_point
			show_plantable(can_plant)
		TOOL.GROW:
			can_grow = false
			if Game.player_raycast.colliding:
				if Game.player_raycast.hit_point.distance_to(Game.player.global_translation) < GROW_TOOL_DISTANCE:
					can_grow = true
					plant_to_grow = Game.player_raycast.collider
			show_growable(can_grow)
		TOOL.ANALYSIS:
			can_analyse = false
			if Game.player_raycast.colliding:
				if Game.player_raycast.hit_point.distance_to(Game.player.global_translation) < ANALYSE_TOOL_DISTANCE:
					can_analyse = true
					object_to_analyse = Game.player_raycast.collider
			show_analysable(can_analyse)

func show_analysable(b: bool):
	Game.UI.crosshair.modulate = Color.green if b else Color.black

func show_growable(b: bool):
	Game.UI.crosshair.modulate = Color.green if b else Color.black

func show_plantable(b: bool):
	Game.UI.crosshair.modulate = Color.green if b else Color.black

const DIRT_EXPLOSION = preload("res://Effects/DirtExplosion.tscn")
func start_planting_animation(pos: Vector3):
	show_plantable(false)
	$Cooldown.start(1)
	$SeedFlyTween.interpolate_property(fake_seed, "global_translation", fake_seed.global_translation, pos, .2)
	$SeedFlyTween.start()
	yield($SeedFlyTween, "tween_all_completed")
	fake_seed.visible = false
	spawn_plant(pos)
	yield(get_tree().create_timer(.6),"timeout")
	fake_seed.visible = true
	fake_seed.global_translation = $SeedPosition.global_translation
	

func spawn_plant(pos: Vector3):
	var new_plant = PLANT.instance()
	Game.planet.add_plant(new_plant)
	new_plant.profile = selected_profile
	new_plant.setup()
	new_plant.global_translation = pos
	new_plant.global_transform.basis = Utility.get_basis_y_alligned(Game.planet.global_translation.direction_to(pos))
	var explosion = DIRT_EXPLOSION.instance()
	Game.planet.add_child(explosion)
	explosion.global_transform = new_plant.global_transform

func show_analyse_information():
	# TODO
	Game.UI.set_diagnostics(["Analysing Object", current_analyse_object, "Analyse Progress", current_analyse_progress * 100.0])
