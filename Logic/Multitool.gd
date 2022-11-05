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
const GROW_TOOL_DISTANCE = 5.0
var can_grow := false
var plant_to_grow: Plant


var first_action_holded := false
func _physics_process(delta):
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
			first_action_holded = true
			process_first_action()
		if Input.is_action_just_released("first_action"):
			first_action_holded = false
		if Input.is_action_just_pressed("second_action"):
			process_first_action()
		idle_process(delta)

# Collision masks
# 0 - Collision
# 1 - Gravity
# 2 - Analysis
# 3 - Bad Planting
# 4 - Moveable

func switch_to_tool(new_tool: int):
	if new_tool == current_tool:
		return
	current_tool = new_tool
	
	if is_instance_valid(fake_seed):
		fake_seed.queue_free()
	
	match current_tool:
		TOOL.NONE:
			pass
		TOOL.PLANT:
			Game.player_raycast.set_collision_mask_bit(0, true)
			Game.player_raycast.set_collision_mask_bit(1, false)
			Game.player_raycast.set_collision_mask_bit(2, false)
			Game.player_raycast.set_collision_mask_bit(3, false)
			Game.player_raycast.set_collision_mask_bit(4, false)
			Game.player_raycast.set_collision_mask_bit(5, false)
			selected_profile = PlantData.profiles[target_plant_name]
			if not seeds_empty:
				fake_seed = FAKE_SEED.instance()
				$SeedPosition.add_child(fake_seed)
				var seed_model = selected_profile.model_seed.instance()
				fake_seed.add_child(seed_model)
		TOOL.MOVE:
			Game.player_raycast.set_collision_mask_bit(0, false)
			Game.player_raycast.set_collision_mask_bit(1, false)
			Game.player_raycast.set_collision_mask_bit(2, false)
			Game.player_raycast.set_collision_mask_bit(3, false)
			Game.player_raycast.set_collision_mask_bit(4, true)
			Game.player_raycast.set_collision_mask_bit(5, false)
		TOOL.ANALYSIS:
			Game.player_raycast.set_collision_mask_bit(0, false)
			Game.player_raycast.set_collision_mask_bit(1, false)
			Game.player_raycast.set_collision_mask_bit(2, true)
			Game.player_raycast.set_collision_mask_bit(3, false)
			Game.player_raycast.set_collision_mask_bit(4, false)
			Game.player_raycast.set_collision_mask_bit(5, false)
		TOOL.GROW:
			Game.player_raycast.set_collision_mask_bit(0, false)
			Game.player_raycast.set_collision_mask_bit(1, false)
			Game.player_raycast.set_collision_mask_bit(2, false)
			Game.player_raycast.set_collision_mask_bit(3, false)
			Game.player_raycast.set_collision_mask_bit(4, false)
			Game.player_raycast.set_collision_mask_bit(5, true)

func idle_process(delta: float):
	match current_tool:
		TOOL.GROW:
			if first_action_holded and can_grow:
				plant_to_grow.growth_boost = true

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
			if Game.player_raycast.colliding:
				if Game.player_raycast.hit_point.distance_to(Game.player.global_translation)

func show_plantable(b: bool):
	Game.UI.crosshair.modulate = Color.green if b else Color.black

func start_planting_animation(pos: Vector3):
	# TODO Fly Animation
	spawn_plant(pos)
	show_plantable(false)
	$Cooldown.start(1)

func spawn_plant(pos: Vector3):
	var new_plant = PLANT.instance()
	Game.planet.add_plant(new_plant)
	new_plant.profile = selected_profile
	new_plant.setup()
	new_plant.global_translation = pos
	new_plant.global_transform.basis = Utility.get_basis_y_alligned(Game.planet.global_translation.direction_to(pos))
