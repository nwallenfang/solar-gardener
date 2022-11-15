extends Spatial
class_name Multitool

enum TOOL {NONE, PLANT, GROW, ANALYSIS, MOVE, BUILD, HOPPER}
var current_tool := 0
var tool_unlocked = {
	TOOL.NONE: true,
	TOOL.PLANT: false,
	TOOL.GROW: false,
	TOOL.ANALYSIS: true,
	TOOL.BUILD: false,
	TOOL.MOVE:false,
	TOOL.HOPPER:true,
	TOOL.BUILD:false,
}

# Preloads
const FAKE_SEED = preload("res://Plants/FakeSeed.tscn")
const PLANT = preload("res://Plants/Plant.tscn")

# Plant Tool Variables
var target_plant_name := "A Testy"
var selected_profile : PlantProfile
var seeds_empty := false
var can_plant := false
var plant_spawn_position := Vector3.ZERO
var fake_seed : Spatial

# Grow Tool Variables
const GROW_TOOL_DISTANCE = 15.0
var can_grow := false
var plant_to_grow: Plant
var grow_beam_active := false
var growth_juice := 1.0
const JUICE_DRAIN = .25
const JUICE_GAIN = .05

# Analysis Variable
const ANALYSE_TOOL_DISTANCE = 10.0
const ANALYSE_SPEED = 1.0/2.0
const SOIL_ANALYSE_SPEED = 1.0/5.0
var can_analyse := false
var currently_analysing := false
var analyse_completed := false
var object_to_analyse: Spatial
var current_analyse_object: Spatial
var current_analyse_progress := 0.0
var soil_analysing := false

# Hopper Variable
var pre_hopper_tool: int
var hopper_planet: Planet
var hopper_pos: Vector3

# Move Variable
var can_move := false
var object_to_move : Spatial

var first_action_holded := false
var second_action_holded := false
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
				switch_to_tool(TOOL.MOVE)
			if Input.is_action_just_pressed("first_action"):
				process_first_action()
			first_action_holded = Input.is_action_pressed("first_action")
			if Input.is_action_just_pressed("second_action"):
				process_second_action()
			second_action_holded = Input.is_action_pressed("second_action")
			idle_process(delta)

	show_scanner_grid(currently_analysing)

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
			#$Model/Grow.visible = false
		TOOL.PLANT:
			Game.player_raycast.set_collision_mask_bit(0, false)
			if is_instance_valid(fake_seed):
				fake_seed.queue_free()
		TOOL.MOVE:
			Game.player_raycast.set_collision_mask_bit(4, false)
			#$Model/Move.visible = false
		TOOL.ANALYSIS:
			Game.player_raycast.set_collision_mask_bit(2, false)
			#$Model/Analysis.visible = false
		TOOL.HOPPER:
			show_hopable(false)

func activate_tool(activated_tool: int):
	Game.UI.get_node("Toolbar").activate_tool(activated_tool)
	tool_unlocked[activated_tool] = true

func switch_to_tool(new_tool: int):
	# return immediately if tool isnt activated
	if not tool_unlocked[new_tool]:
		return
	
	if new_tool == current_tool:
		return
	switch_away_from_tool(current_tool)
	current_tool = new_tool
	Game.UI.get_node("Toolbar").switch_to(new_tool)
	match current_tool:
		TOOL.PLANT:
			Game.player_raycast.set_collision_mask_bit(0, true)
			selected_profile = PlantData.profiles[target_plant_name]
			if not PlantData.seed_counts[target_plant_name] == 0:
				seeds_empty = false
				fake_seed = FAKE_SEED.instance()
				$SeedPosition.add_child(fake_seed)
				fake_seed.setup(target_plant_name)
			else:
				seeds_empty = true
		TOOL.MOVE:
			Game.player_raycast.set_collision_mask_bit(4, true)
			#$Model/Move.visible = true
		TOOL.ANALYSIS:
			Game.player_raycast.set_collision_mask_bit(2, true)
			#$Model/Analysis.visible = true
		TOOL.GROW:
			Game.player_raycast.set_collision_mask_bit(5, true)
			#$Model/Grow.visible = true
		TOOL.HOPPER:
			show_hopable(true)

func idle_process(delta: float):
	growth_juice = min(1.0, growth_juice + JUICE_GAIN * delta)
	
	match current_tool:
		TOOL.PLANT:
			show_plant_information()
		TOOL.GROW:
			if first_action_holded and can_grow and $GrowCooldown.time_left == 0.0:
				grow_beam_active = true
				plant_to_grow.growth_boost = true
				growth_juice -= JUICE_DRAIN * delta
				if growth_juice <= 0.0:
					growth_juice = 0.0
					$GrowCooldown.start(2.0)
			else:
				grow_beam_active = false
			show_grow_information()
		TOOL.ANALYSIS:
			analyse_completed = false
			if not currently_analysing:
				if can_analyse and first_action_holded:
					currently_analysing = true
					current_analyse_object = object_to_analyse
					current_analyse_progress = 0.0
			if currently_analysing:
				if (not first_action_holded) or object_to_analyse != current_analyse_object or (not can_analyse):
					currently_analysing = false
				else:
					var speed_factor := 1.0
					if "analyse_speed_factor" in current_analyse_object:
						speed_factor = current_analyse_object.get("analyse_speed_factor")
					current_analyse_progress += ANALYSE_SPEED * delta * speed_factor
					if current_analyse_progress >= 1.0:
						currently_analysing = false
						analyse_completed = true
						$Cooldown.start(2)
						print("Analysis Done of " + str(current_analyse_object))
						if current_analyse_object.has_method("on_analyse"):
							current_analyse_object.call("on_analyse")
			show_analyse_information()

func process_first_action():
	match current_tool:
		TOOL.PLANT:
			if can_plant and PlantData.can_plant(target_plant_name):
				PlantData.plant(target_plant_name)
				start_planting_animation(plant_spawn_position)
		TOOL.HOPPER:
			$Cooldown.start(2)
			Game.execute_planet_hop(hopper_planet, hopper_pos)
			switch_to_tool(pre_hopper_tool)

func process_second_action():
	match current_tool:
		TOOL.MOVE:
			if object_to_move != null and object_to_move.has_method("on_remove"):
				object_to_move.call("on_remove")
				$Cooldown.start(2)

func check_on_hover():
	Game.player_raycast.do_cast()
	if Game.player_raycast.collider is Planet and current_tool != TOOL.HOPPER:
		pre_hopper_tool = current_tool
		switch_to_tool(TOOL.HOPPER)
	match current_tool:
		TOOL.PLANT:
			if Game.player_raycast.colliding:
				can_plant = Utility.test_planting_position(Game.player_raycast.hit_point) # and PlantData.can_plant() TODO
			else:
				can_plant = false
			plant_spawn_position = Game.player_raycast.hit_point
			if seeds_empty:
				can_plant = false
			show_plantable(can_plant)
		TOOL.GROW:
			can_grow = false
			if Game.player_raycast.colliding:
				if Game.player_raycast.hit_point.distance_to(Game.player.global_translation) < GROW_TOOL_DISTANCE:
					plant_to_grow = Game.player_raycast.collider as Plant
					can_grow = plant_to_grow.growth_beam_possible()
			show_growable(can_grow)
		TOOL.MOVE:
			can_move = false
			if Game.player_raycast.colliding:
				if Game.player_raycast.hit_point.distance_to(Game.player.global_translation) < GROW_TOOL_DISTANCE:
					can_move = true
					object_to_move = Game.player_raycast.collider
			show_moveable(can_move)
		TOOL.ANALYSIS:
			can_analyse = false
			object_to_analyse = null
			if Game.player_raycast.colliding:
				if Game.player_raycast.hit_point.distance_to(Game.player.global_translation) < ANALYSE_TOOL_DISTANCE:
					can_analyse = true
					object_to_analyse = Game.player_raycast.collider
					if object_to_analyse is StaticBody:
						object_to_analyse = Game.planet
			show_analysable(can_analyse)
		TOOL.HOPPER:
			if not (Game.player_raycast.colliding and Game.player_raycast.collider is Planet):
				switch_to_tool(pre_hopper_tool)
			else:
				hopper_planet = Game.player_raycast.collider
				hopper_pos = Game.player_raycast.hit_point

func show_moveable(b: bool):
	if b:
		Game.crosshair.set_style(Game.crosshair.Style.ACTION)
	else:
		Game.crosshair.set_style(Game.crosshair.Style.DEFAULT)

func show_analysable(b: bool):
	if b:
		Game.crosshair.set_style(Game.crosshair.Style.SCANNER)
	else:
		Game.crosshair.set_style(Game.crosshair.Style.DEFAULT)

func show_growable(b: bool):
	if b:
		Game.crosshair.set_style(Game.crosshair.Style.ACTION)
	else:
		Game.crosshair.set_style(Game.crosshair.Style.DEFAULT)

func show_plantable(b: bool):
	if b:
		Game.crosshair.set_style(Game.crosshair.Style.PLANT)
	else:
		Game.crosshair.set_style(Game.crosshair.Style.DEFAULT)

func show_hopable(b: bool):
	if b:
		Game.crosshair.set_style(Game.crosshair.Style.HOP)
	else:
		Game.crosshair.set_style(Game.crosshair.Style.DEFAULT)

func start_planting_animation(pos: Vector3):
	show_plantable(false)
	$Cooldown.start(1)
	$SeedFlyTween.interpolate_property(fake_seed, "global_translation", fake_seed.global_translation, pos, .2)
	$SeedFlyTween.start()
	yield($SeedFlyTween, "tween_all_completed")
	fake_seed.visible = false
	spawn_plant(pos)
	yield(get_tree().create_timer(.6),"timeout")
	fake_seed.global_translation = $SeedPosition.global_translation
	if not PlantData.seed_counts[target_plant_name] == 0:
		seeds_empty = false
		fake_seed.visible = true
	else:
		seeds_empty = true

const DIRT_EXPLOSION = preload("res://Effects/DirtExplosion.tscn")
const DIRT_PILE = preload("res://Assets/Models/ModelDirtPile.tscn")
func spawn_plant(pos: Vector3):
	var new_plant = PLANT.instance()
	Game.planet.add_plant(new_plant)
	new_plant.profile = selected_profile
	new_plant.setup()
	new_plant.global_translation = pos
	new_plant.global_transform.basis = Utility.get_basis_y_aligned(Game.planet.global_translation.direction_to(pos))
	new_plant.planet = Game.planet
	var explosion = DIRT_EXPLOSION.instance()
	Game.planet.add_child_with_light(explosion)
	explosion.global_transform = new_plant.global_transform
	var pile = DIRT_PILE.instance()
	new_plant.add_child(pile)
	Game.planet.add_to_lod_list(pile)
	pile.global_translation = pos
	pile.global_transform.basis = Utility.get_basis_y_aligned(Game.planet.global_translation.direction_to(pos))

func show_analyse_information():
	#Game.UI.set_diagnostics(["Analysing Object", current_analyse_object, "Analyse Progress", current_analyse_progress * 100.0])
	var text := ""
	if object_to_analyse != null:
		if "analyse_name" in object_to_analyse:
			text = object_to_analyse.get("analyse_name")
	if currently_analysing:
		text = text + "\n%.0f%%" % (current_analyse_progress * 100.0)
	else:
		text = text + ("\n100%" if analyse_completed else "")
	set_display_label(text)

func show_grow_information():
	set_display_label("%.0f%%" % (growth_juice * 100.0) + ("\n!" if grow_beam_active else ""))

func show_plant_information():
	var seeds_left = PlantData.seed_counts[target_plant_name]
	set_display_label(str(seeds_left))

func set_display_label(s: String):
	$"%DisplayLabel".text = s

var scanner_grid_last_frame := false
var scanned_meshes := []
const SCANNER_GRID = preload("res://Assets/Materials/ScannerGrid.tres")
func show_scanner_grid(show: bool):
	if show:
		if not scanner_grid_last_frame:
			var dir : Vector3 = Vector3.UP
			if current_analyse_object != Game.planet:
				dir = Game.planet.global_translation.direction_to(current_analyse_object.global_translation)
				scanned_meshes = Utility.get_all_mesh_instance_children(current_analyse_object)
			else:
				scanned_meshes = Utility.get_all_mesh_instance_children(Game.planet.get_node("Model"))
			SCANNER_GRID.set_shader_param("direction", dir)
			for mi in scanned_meshes:
				mi.material_overlay = SCANNER_GRID
	else:
		if scanner_grid_last_frame:
			for mi in scanned_meshes:
				mi.material_overlay = null
			scanned_meshes = []
	scanner_grid_last_frame = show
