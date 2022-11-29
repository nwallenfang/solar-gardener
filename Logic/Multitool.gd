extends Spatial
class_name Multitool

enum TOOL {NONE, ANALYSIS, PLANT, GROW, MOVE, BUILD, HOPPER}
var current_tool :int = TOOL.NONE
var tool_unlocked = {
	TOOL.NONE: true,
	TOOL.PLANT: false,
	TOOL.GROW: false,
	TOOL.ANALYSIS: true,
	TOOL.BUILD: false,
	TOOL.MOVE: false,
	TOOL.HOPPER: false,
}
const tooltips := {
	TOOL.PLANT: ["Click", "Plant a seed"],
	TOOL.ANALYSIS: ["Click", "Scan object"],
	TOOL.GROW: ["Click", "Speed up growth"],
	TOOL.HOPPER: ["Click", "Hop to planet"],
}

# Preloads
const FAKE_SEED = preload("res://Plants/FakeSeed.tscn")
const PLANT = preload("res://Plants/Plant.tscn")

# Plant Tool Variables
const PLANT_TOOL_DISTANCE = 20.0
var target_plant_name := "Grabroot"
var selected_profile : PlantProfile
var seeds_empty := false
var can_plant := false
var plant_spawn_position := Vector3.ZERO
var fake_seed : Spatial
var last_problem_areas := []
var ignore_first_check_visually := false # dirty code hack shit

# Grow Tool Variables
const GROW_TOOL_DISTANCE = 15.0
var can_grow := false
var plant_to_grow: Plant
var grow_beam_active := false
var growth_juice := 1.0
const JUICE_DRAIN = .25
const JUICE_GAIN = .05

var death_beam_unlocked := false
var death_beam_active := false
var death_beam_progress := 0.0
var death_beam_target: Plant

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
var soil_unlocked := false

# Hopper Variable
var pre_hopper_tool: int
var hopper_planet: Planet
var hopper_pos: Vector3
var hop_mode := false

# Upgrade
var upgrade_mode := false setget set_upgrade_mode
func set_upgrade_mode(x: bool):
	upgrade_mode = x
	show_upgradable(x)
var upgrade_station: UpgradeStation

# Move Variable
var can_move := false
var object_to_move : Spatial

# Input Variables
var first_action_holded := false
var second_action_holded := false

# Cooldown
var waiting_for_animation := false
func has_no_cooldown() -> bool:
	return $Cooldown.time_left == 0.0 and not waiting_for_animation

func wait_for_animation_finished():
	waiting_for_animation = true
	yield($ModelMultitool,"animation_finished")
	waiting_for_animation = false

func _physics_process(delta):
	if Game.game_state == Game.State.INGAME:
		check_input_on_cooldown()
		if has_no_cooldown():
			check_on_hover()
			check_input()
			idle_process(delta)
		else:
			if hop_mode:
				if Input.is_action_just_pressed("first_action"):
					Game.execute_planet_hop(hopper_planet, hopper_pos)
					switch_tool(pre_hopper_tool)
					hop_mode = false
		if upgrade_mode:
			if Input.is_action_just_pressed("first_action"):
				upgrade_station.upgrade()
				self.upgrade_mode = false
			
		if (seeds_empty and current_tool == TOOL.PLANT) or force_reload:
			try_reload()

	show_scanner_grid(currently_analysing)
#	if should_update_fake_seed_position:
#		update_fake_seed_position()
	
var switched_tool_on_cooldown :int= TOOL.ANALYSIS setget set_switched_on_cooldown
func set_switched_on_cooldown(set_tool: int):
	if hop_mode:
		print("Hop Blocked Tool Switch")
		return
	if tool_unlocked[set_tool]:
		switched_tool_on_cooldown = set_tool
		emit_signal("switched_to", set_tool)

func check_input_on_cooldown():
	if Input.is_action_just_pressed("tool1"):
		self.switched_tool_on_cooldown = TOOL.ANALYSIS
	if Input.is_action_just_pressed("tool2"):
		self.switched_tool_on_cooldown = TOOL.PLANT
	if Input.is_action_just_pressed("tool3"):
		self.switched_tool_on_cooldown = TOOL.GROW

func check_input():
	if switched_tool_on_cooldown == TOOL.ANALYSIS:
		switch_tool(TOOL.ANALYSIS)
		emit_signal("switched_to", TOOL.ANALYSIS)
	if switched_tool_on_cooldown == TOOL.PLANT:
		switch_tool(TOOL.PLANT)
		emit_signal("switched_to", TOOL.PLANT)
	if switched_tool_on_cooldown == TOOL.GROW:
		switch_tool(TOOL.GROW)
		emit_signal("switched_to", TOOL.GROW)
	switched_tool_on_cooldown = TOOL.NONE
	if Input.is_action_just_pressed("first_action") and not Game.coming_out_of_journal:
		process_first_action()
	first_action_holded = Input.is_action_pressed("first_action") and not Game.coming_out_of_journal
	if Input.is_action_just_pressed("second_action"):
		process_second_action()
	second_action_holded = Input.is_action_pressed("second_action")

	Game.coming_out_of_journal = false

# Collision masks
# 0 - Collision
# 1 - Gravity
# 2 - Analysis
# 3 - Bad Planting
# 4 - Moveable

func activate_tool(activated_tool: int):
	Game.UI.get_node("Toolbar").activate_tool(activated_tool)
	tool_unlocked[activated_tool] = true

var currently_switching := false
signal switched_to(new_tool)
func switch_tool(new_tool: int, tool_active := true):
	if tool_active:
		# return immediately if tool isnt activated
		if not tool_unlocked[new_tool]:
			return
		
		if new_tool == current_tool:
			return
		
		currently_switching = true
		clear_holo_information()
		if new_tool != TOOL.HOPPER:
			Game.crosshair.set_style(Game.crosshair.Style.DEFAULT)
		else:
			show_hopable(tool_active)
		# dirty coded so that hovering hopper doesn't play stop sound
		if current_tool == TOOL.GROW and new_tool != TOOL.HOPPER:
			Audio.play("growbeam_close")
		switch_tool(current_tool, false)
		if waiting_for_animation:
			yield($ModelMultitool,"animation_finished")
		current_tool = new_tool

	match new_tool:
		TOOL.PLANT:
			if not tool_active:
				for area in last_problem_areas:
					if is_instance_valid(area):
						area.get_node("BadPlantingVisuals").visible = false
				last_problem_areas.clear()
			if is_instance_valid(fake_seed):
				fake_seed.queue_free()
			#Game.player_raycast.set_collision_mask_bit(0, tool_active)
			$ModelMultitool.set_plant(tool_active)
			wait_for_animation_finished()
			yield($ModelMultitool,"animation_finished")
			force_reload = tool_active
		TOOL.MOVE:
			Game.player_raycast.set_collision_mask_bit(4, tool_active)
		TOOL.ANALYSIS:
			Game.player_raycast.set_collision_mask_bit(2, tool_active)
			$ModelMultitool.set_analysis(tool_active)
			wait_for_animation_finished()
		TOOL.GROW:
			if tool_active:
				Audio.play("growbeam_pulse")
				Audio.fade_in("growbeam_rotate_slow")
			else:
				Audio.stop("growbeam_pulse")
				Audio.fade_out("growbeam_rotate_slow", 0.6)
				Audio.fade_out("growbeam_rotate_fast", 0.6)
			Game.player_raycast.set_collision_mask_bit(5, tool_active)
			$ModelMultitool.set_grow(tool_active)
			wait_for_animation_finished()
		TOOL.HOPPER:
			show_hopable(tool_active)
			$ModelMultitool.set_hopper(tool_active)
			wait_for_animation_finished()
	if waiting_for_animation:
		yield($ModelMultitool,"animation_finished")
	currently_switching = false

func idle_process(delta: float):
	growth_juice = min(1.0, growth_juice + JUICE_GAIN * delta)
	
	match current_tool:
		TOOL.PLANT:
			show_plant_information()
		TOOL.GROW:
			if first_action_holded and can_grow and $GrowCooldown.time_left == 0.0:
				if not grow_beam_active:
					Audio.fade_in("growbeam", 0.25, true)
					Audio.fade_in("growbeam_rotate_fast", 0.2)
					Audio.fade_out("growbeam_rotate_slow", 0.2)
					grow_beam_active = true
					plant_to_grow.play_growth_flash()
				plant_to_grow.growth_boost = true
				growth_juice -= JUICE_DRAIN * delta
				if growth_juice <= 0.0:
					growth_juice = 0.0
					$GrowCooldown.start(2.0)
			else:
				if grow_beam_active:
					Audio.fade_out("growbeam", 0.4)
					Audio.fade_out("growbeam_rotate_fast", 0.2)
					Audio.fade_in("growbeam_rotate_slow", 0.2)
				grow_beam_active = false
				
			# Death Beam
			if second_action_holded and (not grow_beam_active) and has_no_cooldown() and death_beam_unlocked and can_grow:
				if not death_beam_active:
					death_beam_target = plant_to_grow
					death_beam_active = true
					death_beam_progress = 0.0
					death_beam_target.play_death_flash()
				death_beam_progress += delta
				if death_beam_progress >= 1.0:
					$Cooldown.start(1.0)
					death_beam_target.call("on_remove")
					death_beam_active = false
			else:
				if death_beam_active:
					death_beam_active = false
					death_beam_target = null
			
			if grow_beam_active:
				$ModelMultitool.set_grow_beam_on_target(plant_to_grow)
			elif death_beam_active:
				$ModelMultitool.set_grow_beam_on_target(death_beam_target, true)
			else:
				$ModelMultitool.set_grow_beam_on_target(null)
			
			show_grow_information()
		TOOL.ANALYSIS:
			if analyse_completed:
				#print("Reset Analyse")
				analyse_completed = false
			if not currently_analysing:
				if can_analyse and first_action_holded:
					Audio.fade_in("scanner", 0.20, true)
					currently_analysing = true
					current_analyse_object = object_to_analyse
					current_analyse_progress = 0.0
			if currently_analysing:
				if (not first_action_holded) or object_to_analyse != current_analyse_object or (not can_analyse):
					currently_analysing = false
					Audio.fade_out("scanner", 0.4)
				else:
					var speed_factor := 1.0
					if "analyse_speed_factor" in current_analyse_object:
						speed_factor = current_analyse_object.get("analyse_speed_factor")
					current_analyse_progress += ANALYSE_SPEED * delta * speed_factor
					if current_analyse_progress >= 1.0:
						Audio.fade_out("scanner", 0.4)
						currently_analysing = false
						analyse_completed = true
						show_analyse_information()
						$Cooldown.start(2)
						print("Analysis Done of " + str(current_analyse_object))
						if current_analyse_object.has_method("on_analyse"):
							if current_analyse_object is Plant:
								if current_analyse_object.can_be_analysed:
									current_analyse_object.call("on_analyse")
							else:
								current_analyse_object.call("on_analyse")
			show_analyse_information()

func process_first_action():
	match current_tool:
		TOOL.PLANT:
			if can_plant and PlantData.can_plant(target_plant_name):
				PlantData.plant(target_plant_name)
				$Cooldown.start(.3)
				ignore_first_check_visually = true
				start_planting_animation(plant_spawn_position)
				show_plant_information(true)
		TOOL.HOPPER:
			$Cooldown.start(2)
			Game.execute_planet_hop(hopper_planet, hopper_pos)
			switch_tool(pre_hopper_tool)
			hop_mode = false

func process_second_action():
	match current_tool:
		TOOL.MOVE:
			if object_to_move != null and object_to_move.has_method("on_remove"):
				object_to_move.call("on_remove")
				$Cooldown.start(2)

func check_on_hover():
#	Game.UI.set_diagnostics(last_problem_areas)
	Game.player_raycast.do_cast()
	if Game.player_raycast.collider is Planet and current_tool != TOOL.HOPPER and "PlanetHopArea" == Game.player_raycast.collider_tag:
		if tool_unlocked[TOOL.HOPPER]:
			hop_mode = true
			pre_hopper_tool = current_tool
			hopper_planet = Game.player_raycast.collider
			hopper_pos = Game.player_raycast.hit_point
			show_hopper_information()
			switch_tool(TOOL.HOPPER)
			return
	else:
		hop_mode = false
	if Game.player_raycast.collider is UpgradeStation and Upgrades.is_upgrade_available():
		self.upgrade_mode = true
	else:
		self.upgrade_mode = false
	match current_tool:
		TOOL.PLANT:
			if Game.player_raycast.colliding and Game.player_raycast.hit_point.distance_to(Game.player.global_translation) < PLANT_TOOL_DISTANCE and Game.planet.is_obsidian == false:
				can_plant = Utility.test_planting_position(Game.player_raycast.hit_point) # and PlantData.can_plant() TODO
				if not can_plant:
					if ignore_first_check_visually:
						yield(get_tree(),"physics_frame")
						yield(get_tree(),"physics_frame")
						ignore_first_check_visually = false
						return
					var problem_areas : Array = Utility.get_last_planting_test_collider_areas()
					var rm_indices = []
					var idx = 0
					for area in last_problem_areas:
						if is_instance_valid(area) and not area in problem_areas:
							rm_indices.append(idx)
							area.get_node("BadPlantingVisuals").visible = false
							idx += 1
					for i in rm_indices:
						last_problem_areas.remove(i)
					
					for area in problem_areas:
						if area is BadPlanting:
							area.get_node("BadPlantingVisuals").visible = true
							if not area in last_problem_areas:
								last_problem_areas.append(area)
				else:
					for area in last_problem_areas:
						if is_instance_valid(area):
							area.get_node("BadPlantingVisuals").visible = false
					last_problem_areas.clear()

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
					if Game.player_raycast.collider is Plant:
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
					if not Game.player_raycast.collider is UpgradeStation:
						can_analyse = true
						object_to_analyse = Game.player_raycast.collider
						if object_to_analyse is Plant:
							can_analyse = true#object_to_analyse.can_be_analysed
						if object_to_analyse is StaticBody:
							if object_to_analyse.name == "PlanetBody" and soil_unlocked:
								object_to_analyse = Game.planet
							else:
								can_analyse = false
						if object_to_analyse.name == "Ice":
							object_to_analyse = object_to_analyse.get_parent()
			show_analysable(can_analyse)
		TOOL.HOPPER:
			if not (Game.player_raycast.colliding and Game.player_raycast.collider is Planet):
				hop_mode = false
				switch_tool(pre_hopper_tool)
			else:
				hopper_planet = Game.player_raycast.collider
				hopper_pos = Game.player_raycast.hit_point
				show_hopper_information()

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

func show_upgradable(b: bool):
	Game.UI.get_node("ClickToUpgrade").visible = b

func start_planting_animation(pos: Vector3):
	show_plantable(false)
	$ModelMultitool.seed_shot()
	$Cooldown.start(1)
	Audio.play("ui_activate1")
	$SeedFlyTween.interpolate_property(fake_seed, "global_translation", fake_seed.global_translation, pos, .2)
	$SeedFlyTween.interpolate_property(fake_seed, "scale", fake_seed.scale, fake_seed.scale * 4.0, .2)
	$SeedFlyTween.start()
	yield(get_tree().create_timer(.2), "timeout")
	fake_seed.visible = false
	spawn_plant(pos)
	yield(get_tree().create_timer(.35), "timeout")
	#fake_seed.global_translation = $SeedPosition.global_translation
	try_reload()

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
	new_plant.dirt_pile = pile
	Game.planet.add_to_lod_list(pile)
	Game.planet.configure_light(pile)
	pile.global_translation = pos
	pile.global_transform.basis = Utility.get_basis_y_aligned(Game.planet.global_translation.direction_to(pos))
	pile.on_lod(false)
	Audio.play("seed_plant_"+str(randi()%3 + 1))
	Events.trigger("tutorial_seed_planted")
	Events.trigger("seed_planted")

var completely_analysed_object = null
func show_analyse_information():
	if has_no_cooldown():
		#Game.UI.set_diagnostics(["Analysing Object", current_analyse_object, "Analyse Progress", current_analyse_progress * 100.0])
		if object_to_analyse != null and is_instance_valid(object_to_analyse):
			if "analyse_name" in object_to_analyse:
				if completely_analysed_object != null:
					if object_to_analyse == completely_analysed_object:
						return
					else:
						completely_analysed_object = null
				Game.hologram.show_scan_progress(object_to_analyse.get("analyse_name"), 0.0)
				if currently_analysing:
					Game.hologram.show_scan_progress(object_to_analyse.get("analyse_name"), current_analyse_progress * 100.0)
				else:
					if analyse_completed:
						completely_analysed_object = object_to_analyse
						if object_to_analyse is Plant:
							if object_to_analyse.can_be_analysed:
								var plant_obj: Plant = object_to_analyse as Plant
								var plant_type: String
								match plant_obj.profile.plant_type:
									PlantData.PLANT_TYPES.THORNY:  # THORNY, SHROOM, FLOWER
										plant_type = "Thorny"
									PlantData.PLANT_TYPES.SHROOM:
										plant_type = "Shroom"
									PlantData.PLANT_TYPES.FLOWER:
										plant_type = "Flower"
								var is_growing = (plant_obj.growth_stage != plant_obj.growth_lock)
								Game.hologram.show_plant_info(plant_obj.profile.name, plant_type, plant_obj.growth_stage, is_growing)
							else:
								Game.hologram.show_analyse_info("Analyse further\ngrown plant\nto get more\ninformation")
						elif object_to_analyse is Planet:
							var planet_obj: Planet = object_to_analyse as Planet
							if planet_obj.is_obsidian:
								Game.hologram.show_analyse_info("Soil too hard\nto plant\nanything")
							else:
								# types: ROCK, DIRT, SAND (2, 3, 4)
								var soil_type: String
								match planet_obj.soil_type:
									PlantData.SOIL_TYPES.ROCK:
										soil_type = "Rock"
									PlantData.SOIL_TYPES.DIRT:
										soil_type = "Dirt"
									PlantData.SOIL_TYPES.SAND:
										soil_type = "Sand"
								if soil_type == null:
									printerr(planet_obj.planet_name + " has weird soil type.")
								Game.hologram.show_soil_info(planet_obj.planet_name, soil_type, planet_obj.nutrients, planet_obj.sun) # type_name: String, has_nutrients:bool, is_close_to_sun: bool)  # TODO
						else:
							if object_to_analyse.has_method("get_analyse_text"):
								Game.hologram.show_analyse_info(object_to_analyse.get_analyse_text())
							else:
								Game.hologram.show_scan_progress(object_to_analyse.get("analyse_name"), 100.0)
			else:
				clear_holo_information()
				completely_analysed_object = null
		else:
			clear_holo_information()
			completely_analysed_object = null


func show_grow_information():
	if has_no_cooldown():
		var is_growing := false
		if plant_to_grow != null and is_instance_valid(plant_to_grow):
			is_growing = (plant_to_grow.growth_stage != plant_to_grow.growth_lock)
		Game.hologram.grow_beam_juice(grow_beam_active, growth_juice, is_growing)

func show_plant_information(force := false):
	if has_no_cooldown() or force:
		var seeds_left = PlantData.seed_counts[target_plant_name]
		if Game.journal.get_got_scanned(target_plant_name):
			Game.hologram.show_seed_info(target_plant_name, seeds_left)
		else:
			Game.hologram.show_seed_info("Unknown", seeds_left)
#	set_display_label(target_plant_name + "\n" + str(seeds_left))

func show_hopper_information():
	if has_no_cooldown():
		Game.hologram.show_hop_info(hopper_planet.planet_name)
#	set_display_label("Travel to " + hopper_planet.planet_name)

func clear_holo_information():
	if Game.hologram != null:
		Game.hologram.clear()
#	set_display_label("")

func set_display_label(s: String, force := false):
	if has_no_cooldown() or force:
		$ModelMultitool.set_holo_text(s)

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

var re_count := 0
var force_reload := false
var currently_reloading := false
func try_reload():
	if current_tool == TOOL.PLANT and (switched_tool_on_cooldown == TOOL.NONE or switched_tool_on_cooldown == TOOL.PLANT) and has_no_cooldown():
		if force_reload:
			force_reload = false
			#print("force reee")
		selected_profile = PlantData.profiles[target_plant_name]
		if not PlantData.seed_counts[target_plant_name] == 0:
			if currently_reloading:
				return
			currently_reloading = true
			#re_count += 1
			#print("REEELOAD" + str(re_count))
			seeds_empty = false
			if is_instance_valid(fake_seed):
				fake_seed.queue_free()
				yield(get_tree(), "idle_frame")
			fake_seed = FAKE_SEED.instance()
			$ModelMultitool/SeedOrigin.add_child(fake_seed)
			fake_seed.setup(target_plant_name, 1.4)
			$ModelMultitool.seed_reload()
			fake_seed.visible = false
			yield(get_tree().create_timer(.1),"timeout")
			if is_instance_valid(fake_seed):
				fake_seed.visible = true
			wait_for_animation_finished()
			yield(get_tree().create_timer(.1),"timeout")
			currently_reloading = false
		else:
			seeds_empty = true

var should_update_fake_seed_position := false
func update_fake_seed_position():
	pass
	#fake_seed.global_translation = $ModelMultitool.get_node("SeedOrigin").global_translation

func set_holo_visible(vis: bool):
	$ModelMultitool.set_holo_visible(vis)
