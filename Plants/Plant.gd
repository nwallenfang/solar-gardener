extends Spatial
class_name Plant

const DEFAULT_GROW_SPEED = 1.0/17.0
const BOOSTED_GROW_SPEED = 1.0/2.5
const DEFAULT_MODEL_SCALE = .9
const GROWTH_UP_SCALE_FACTOR = 1.15
const GROWTH_DOWN_SCALE_FACTOR = .9
const SEED_START_POINT = .1
const SEED_SINK_DISTANCE = .2

var profile: PlantProfile

var growth_points: int = 0
var growth_stage: int = PlantData.GROWTH_STAGES.SEED
var growth_lock: int = PlantData.GROWTH_STAGES.SEED
var growth_stage_progress: float = 0.0

var planet: Planet

var model_seed: Spatial
var model_stage_1: Spatial
var model_stage_2: Spatial
var model_stage_3: Spatial
var model_stage_4: Spatial

var model_array: Array
var current_model: Spatial

var analyse_name : String setget, get_analyse_name

var extra_grounding_distance := 0.0

var can_be_analysed := false

var effect: Spatial

var dirt_pile: Spatial

var is_setup := false
func setup():
	print("plant setup")
	if profile.special_effect != null:
		effect = profile.special_effect.instance()
		add_child(effect)
		effect.setup()
	model_seed = profile.model_seed.instance()
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	model_stage_1 = profile.model_stage_1.instance()
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	model_stage_2 = profile.model_stage_2.instance()
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	model_stage_3 = profile.model_stage_3.instance()
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	model_stage_4 = profile.model_stage_4.instance()
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	model_array = [model_seed, model_stage_1, model_stage_2, model_stage_3, model_stage_4]
	for model in model_array:
		model.visible = false
		add_child(model)
		model.translation.y -= extra_grounding_distance

	model_seed.translation.y = SEED_START_POINT

	current_model = model_seed
	current_model.visible = true
	
	analyse_name = profile.name
	
	is_setup = true
	yield(get_tree(),"idle_frame")
	check_conditions()

var growth_locked_once := false
func _physics_process(delta):
	if lod_mode:
		return
	if growth_stage != growth_lock and $GrowthCooldown.time_left == 0.0:
		if growth_stage != PlantData.GROWTH_STAGES.STAGE_4:
			grow(delta, sign(growth_lock - growth_stage))
	
	if growth_stage == growth_lock:  # not growing anymore
		if growth_boost:
			flush_seeds()
			growth_boost = false

func _on_CheckConditionsTimer_timeout():
#	if growth_stage == growth_lock:
	check_conditions()

var cheat = false
func calculate_growth_points():
	var ability_tags := get_near_plants_tags()
	var points := 0
	# SOIL TYPE
	if profile.prefered_soil == PlantData.SOIL_TYPES.ANY:
		points += 1
	elif profile.prefered_soil == PlantData.SOIL_TYPES.NONE:
		points += 0
	elif profile.prefered_soil == planet.soil_type:
		points += 1
		if growth_stage >= 1:
			match planet.soil_type:
				PlantData.SOIL_TYPES.ROCK:
					Game.journal.make_preference_known(profile.name, "Likes rocky planets")
				PlantData.SOIL_TYPES.DIRT:
					Game.journal.make_preference_known(profile.name, "Likes dirt planets")
				PlantData.SOIL_TYPES.SAND:
					Game.journal.make_preference_known(profile.name, "Likes sandy planets")
	
	# SUN
	var sun_value := planet.sun
	if ("sun_yes" in ability_tags):
		sun_value = true
	elif ("sun_no" in ability_tags):
		sun_value = false
	if ("sun_yes" in ability_tags) and ("sun_no" in ability_tags):
		sun_value = profile.sun == PlantData.PREFERENCE.LIKES
	if profile.sun == PlantData.PREFERENCE.ALWAYS_FALSE:
		points += 0
	elif profile.sun == PlantData.PREFERENCE.ALWAYS_TRUE:
		points += 1
	elif profile.sun == PlantData.PREFERENCE.LIKES:
		if sun_value:
			points += 1
			if growth_stage >= 1:
				Game.journal.make_preference_known(profile.name, "Likes Sun")
	elif profile.sun == PlantData.PREFERENCE.HATES:
		if not sun_value:
			points += 1 
			if growth_stage >= 1:
				Game.journal.make_preference_known(profile.name, "Hates Sun")
	
	# NUTRI
	var nutri_value := planet.nutrients
	if ("nutri_yes" in ability_tags):
		nutri_value = true
	elif ("nutri_no" in ability_tags):
		nutri_value = false
	if ("nutri_yes" in ability_tags) and ("nutri_no" in ability_tags):
		nutri_value = profile.nutrients == PlantData.PREFERENCE.LIKES
	if profile.nutrients == PlantData.PREFERENCE.ALWAYS_FALSE:
		points += 0
	elif profile.nutrients == PlantData.PREFERENCE.ALWAYS_TRUE:
		points += 1
	elif profile.nutrients == PlantData.PREFERENCE.LIKES:
		if nutri_value:
			points += 1
			if growth_stage >= 1:
				Game.journal.make_preference_known(profile.name, "Likes Nutrients")
	elif profile.nutrients == PlantData.PREFERENCE.HATES:
		if not nutri_value:
			points += 1
			if growth_stage >= 1:
				Game.journal.make_preference_known(profile.name, "Hates Nutrients")
	
	#Game.UI.set_diagnostics([get_near_plants_group_count()])
	# GROUP
	if growth_stage != PlantData.GROWTH_STAGES.SEED:
		if profile.group == PlantData.PREFERENCE.ALWAYS_FALSE:
			points += 0
		elif profile.group == PlantData.PREFERENCE.ALWAYS_TRUE:
			points += 1
		elif profile.group == PlantData.PREFERENCE.LIKES:
			
			if get_near_plants_group_count() >= 2:
				points += 1
				if growth_stage >= 1:
					Game.journal.make_preference_known(profile.name, "Likes Groups")
		elif profile.group == PlantData.PREFERENCE.HATES:
			if get_near_plants_group_count() < 1:
				points += 1
				if growth_stage >= 1:
					Game.journal.make_preference_known(profile.name, "Hates Groups")
	
	if profile.symbiosis_plant_type in get_near_plants_types():
		points += 1
		match(profile.symbiosis_plant_type):
			PlantData.PLANT_TYPES.FLOWER:
				Game.journal.make_preference_known(profile.name, "Likes Flowers")
			PlantData.PLANT_TYPES.SHROOM:
				Game.journal.make_preference_known(profile.name, "Likes Shrooms")
			PlantData.PLANT_TYPES.THORNY:
				Game.journal.make_preference_known(profile.name, "Likes Thornys")
	
	# CHEAT
	if cheat: # or profile.name == "Greatcap" or profile.name == "Moontree":
		points += 20
		
	growth_points = points
	

	
func check_conditions():
	calculate_growth_points()
	if growth_points >= profile.points_for_stage_4:
		growth_lock = PlantData.GROWTH_STAGES.STAGE_4
	elif growth_points >= profile.points_for_stage_3:
		growth_lock = PlantData.GROWTH_STAGES.STAGE_3
	elif growth_points >= profile.points_for_stage_2:
		growth_lock = PlantData.GROWTH_STAGES.STAGE_2
	elif growth_points >= profile.points_for_stage_1:
		growth_lock = PlantData.GROWTH_STAGES.STAGE_1
	else:
		growth_lock = PlantData.GROWTH_STAGES.SEED
		
	if (not growth_locked_once) and growth_stage == growth_lock:
		Events.trigger("tutorial_growth_reached")
		growth_locked_once = true

signal growth_stage_reached()
var growth_boost := false
func grow(delta, factor_sign):
	if growth_boost:
		growth_stage_progress += BOOSTED_GROW_SPEED * delta * factor_sign
	else:
		growth_stage_progress += DEFAULT_GROW_SPEED * delta * factor_sign * (2.0 if growth_stage == PlantData.GROWTH_STAGES.SEED else 1.0)
	growth_boost = false
	update_growth_visuals()
	reset_small_seeds()
	if abs(growth_stage_progress) >= 1.0:
		$GrowthCooldown.start()
		var old_stage := growth_stage
		growth_stage = growth_stage + int(factor_sign * 1.1) # "* 1.1" to avoid float error nonsense
		set_animation_active(current_model, false)
		current_model = model_array[growth_stage]
		set_animation_active(current_model, true)
		growth_stage_progress = 0.0

		play_growth_pop_animation(old_stage)
		if growth_stage >= profile.use_big_hitbox_at_stage:
			$Area/CollisionShapeBig.disabled = false

		can_be_analysed = true
		if growth_stage == growth_lock:
			$SeedGrowCooldown.start(profile.seed_grow_time)
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		
		Events.trigger("tutorial_plant_reached_stage" + str(growth_stage))
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		
		PlantData.growth_stage_reached(profile.name, growth_stage)
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		
		if Game.planet == planet:
			planet.growth_stage_reached(growth_stage)
		check_conditions()
		if profile.needs_dirt_pile == false:
			yield(get_tree().create_timer(2), "timeout")
			if is_instance_valid(dirt_pile):
				dirt_pile.queue_free()
		#$Area.set_collision_layer_bit(2, true)

func set_animation_active(model: Spatial, active: bool):
	if model.has_method("animate"):
		model.call("animate")
	elif model.has_node("AnimationPlayer"):
		var anim: AnimationPlayer = model.get_node("AnimationPlayer")
		
#		if anim.has_animation("Key001Action"):
#			if active:
#				anim.play("Key001Action")
		if not active:
			anim.stop()


const GREEN_OVERLAY = preload("res://Assets/Materials/GreenAlphaOverlay.tres")
const GROW_POP_PARTICLES = preload("res://Effects/GrowPopParticles.tscn")
func play_growth_pop_animation(old_stage):
	# TODO profile this function
	var old_meshes : Array = Utility.get_all_mesh_instance_children(model_array[old_stage])
	var new_meshes : Array = Utility.get_all_mesh_instance_children(current_model)
	for mi in old_meshes:
		mi = mi as MeshInstance
		mi.material_overlay = GREEN_OVERLAY.duplicate()
		$GrowthAnimationTween.interpolate_property(mi.material_overlay, "albedo_color:a", 0.0, 1.0, .7,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$GrowthAnimationTween.start()
	yield($GrowthAnimationTween,"tween_all_completed")
	model_array[old_stage].visible = false
	model_array[old_stage].scale = Vector3.ONE * DEFAULT_MODEL_SCALE
	current_model.scale = Vector3.ONE * DEFAULT_MODEL_SCALE
	current_model.visible = true

	for mi in old_meshes:
		mi = mi as MeshInstance
		mi.material_overlay = null
	for mi in new_meshes:
		mi = mi as MeshInstance
		mi.material_overlay = GREEN_OVERLAY.duplicate()
		$GrowthAnimationTween.interpolate_property(mi.material_overlay, "albedo_color:a", 1.0, 0.0, 1.0,Tween.TRANS_QUAD,Tween.EASE_IN)
	$GrowthAnimationTween.start()
	var grow_pop_part := GROW_POP_PARTICLES.instance()
	add_child(grow_pop_part)

	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var dist:= self.global_translation.distance_to(Game.player.global_translation)
	Audio.play_growth_stage(profile.name, growth_stage, dist)
	yield($GrowthAnimationTween,"tween_all_completed")
	for mi in new_meshes:
		mi = mi as MeshInstance
		mi.material_overlay = null

const FLASH_OVERLAY = preload("res://Assets/Materials/FlashAlphaOverlay.tres")
func play_growth_flash():
	if growth_stage != growth_lock and growth_stage_progress < .75:
		var meshes : Array = Utility.get_all_mesh_instance_children(current_model)
		for mi in meshes:
			mi.material_overlay = FLASH_OVERLAY
		$FlashTween.interpolate_property(FLASH_OVERLAY, "albedo_color:a", 0.0, 0.5, .15, Tween.TRANS_QUAD, Tween.EASE_IN)
		$FlashTween.start()
		yield($FlashTween,"tween_all_completed")
		$FlashTween.interpolate_property(FLASH_OVERLAY, "albedo_color:a", 0.5, 0.0, .3, Tween.TRANS_QUAD, Tween.EASE_IN)
		$FlashTween.start()
		yield($FlashTween,"tween_all_completed")
		for mi in meshes:
			mi.material_overlay = null

const DEATH_OVERLAY = preload("res://Assets/Materials/DeathAlphaOverlay.tres")
func play_death_flash():
	var meshes : Array = Utility.get_all_mesh_instance_children(current_model)
	for mi in meshes:
		mi.material_overlay = DEATH_OVERLAY
	$FlashTween.interpolate_property(DEATH_OVERLAY, "albedo_color:a", 0.0, 0.5, .15, Tween.TRANS_QUAD, Tween.EASE_IN)
	$FlashTween.start()
	yield($FlashTween,"tween_all_completed")
	$FlashTween.interpolate_property(DEATH_OVERLAY, "albedo_color:a", 0.5, 0.0, .3, Tween.TRANS_QUAD, Tween.EASE_IN)
	$FlashTween.start()
	yield($FlashTween,"tween_all_completed")
	for mi in meshes:
		mi.material_overlay = null

func update_growth_visuals():
	if growth_stage == 0:
		model_seed.translation.y = SEED_START_POINT - SEED_SINK_DISTANCE * growth_stage_progress
	else:
		var scale_vector := Vector3.ONE
		if growth_stage_progress <= 0.0:
			scale_vector *= lerp(DEFAULT_MODEL_SCALE, GROWTH_DOWN_SCALE_FACTOR, -growth_stage_progress)
		else:
			scale_vector *= lerp(DEFAULT_MODEL_SCALE, GROWTH_UP_SCALE_FACTOR, growth_stage_progress)
		current_model.scale = scale_vector

const FLYING_PICKUP = preload("res://Objects/FlyingPickup.tscn")

var removing := false
func on_remove():
	if removing:
		return
	removing = true
	if seeds_ready_to_harvest:
		flush_seeds()
	else:
		reset_small_seeds()
	var pickup = FLYING_PICKUP.instance()
	Game.planet.add_child_with_light(pickup)
	pickup.global_transform.basis = Utility.get_basis_y_aligned(Game.planet.global_translation.direction_to(self.global_translation))
	pickup.global_translation = self.global_translation
	pickup.setup_as_seed(profile.name)

	$RemoveTween.interpolate_property(self, "scale", Vector3.ONE, Vector3.ONE * .01, 2.5)
	$RemoveTween.start()
	yield(get_tree().create_timer(1.5), "timeout")
	pickup.start_flying()
	yield($RemoveTween, "tween_all_completed")
	queue_free()

func on_analyse():
	Game.journal.plant_got_scanned(profile.name, growth_stage)
	Events.trigger("tutorial_plant_scanned")
	Game.shed.trigger_trophy(profile.name)
	show_symb_visuals()

func growth_beam_possible() -> bool:
	return true
	#return $GrowthCooldown.time_left == 0.0

var small_seeds := []
var seeds_ready_to_harvest := false
func grow_small_seeds():
	if not small_seeds.empty():
		return

	var empty_spaces := []
	for c in current_model.get_children():
		c = c as Node
		if "empty" in c.name.to_lower() and c is Spatial:
			empty_spaces.append(c)
	for empty in empty_spaces:
		var pickup = FLYING_PICKUP.instance()
		Game.planet.add_child_with_light(pickup)
		Game.planet.add_to_lod_list(pickup)
		pickup.global_transform.basis = Utility.get_basis_y_aligned(Game.planet.global_translation.direction_to(self.global_translation))
		pickup.global_translation = empty.global_translation
		pickup.setup_as_seed(profile.name, .4, false, false)
		small_seeds.append(pickup)
		Game.planet.add_to_lod_list(pickup)
	yield(get_tree().create_timer(2),"timeout")
	seeds_ready_to_harvest = true


func reset_small_seeds():
	for pickup in small_seeds:
		pickup.queue_free()
	small_seeds = []
	$SeedGrowCooldown.stop()
	seeds_ready_to_harvest = false

func flush_seeds():
	if not seeds_ready_to_harvest:
		return
	seeds_ready_to_harvest = false
	Events.trigger("seeds_harvested")
	for pickup in small_seeds:
		$SeedGrowTween.interpolate_property(pickup, "scale", pickup.scale, pickup.scale * 1.8, 1.0)
	$SeedGrowTween.start()
	yield($SeedGrowTween, "tween_all_completed")
	for pickup in small_seeds:
		pickup.start_flying()
	small_seeds = []
	$SeedGrowCooldown.start(profile.seed_grow_time)

func get_near_symbiosis_objects_list() -> Array:
	var objects := []
	for collider in $SymbiosisArea.get_overlapping_areas():
		var collider_parent = collider.get_parent() as Node
		if not collider_parent.is_class("Plant"):
			objects.append(collider_parent)
	return objects

func get_near_plants_list() -> Array:
	var plants := []
	for collider in $SymbiosisArea.get_overlapping_areas():
		var collider_parent = collider.get_parent() as Node
		if collider_parent.is_class("Plant"):
			if collider_parent.growth_stage != PlantData.GROWTH_STAGES.SEED:
				plants.append(collider_parent)
	return plants

func get_near_plants_group_count() -> int:
	var plants := get_near_plants_list()
	var count := 0
	for plant in plants:
		plant = plant as Plant
		if plant.profile.name == self.profile.name:
			count += 1
	return count

func get_near_plants_types() -> Array:
	var plants := get_near_plants_list()
	var types := []
	for plant in plants:
		if self.profile.name != plant.profile.name:
			types.append(plant.profile.plant_type)
	return types

func get_near_plants_tags() -> Array:
	var plants := get_near_plants_list()
	var list := []
	for plant in plants:
		for tag in plant.get_ability_tags():
			if not tag in list:
				list.append(tag)
	return list

func get_ability_tags() -> Array:
	if effect != null:
		if effect.has_method("get_ability_tags"):
			var effect_return = effect.call("get_ability_tags")
			if effect_return != null:
				return effect_return
	return []

func get_analyse_name() -> String:
	if analyse_name in Game.journal.scanned_plant_names:
		return analyse_name
	else:
		return "Unknown Plant"

func _on_SeedGrowCooldown_timeout():
	grow_small_seeds()

func is_class(value):
	return value == "Plant"

var lod_mode := false
func on_lod(lod_triggered: bool):
	if lod_triggered:
		$CheckConditionsTimer.stop()
		$SeedGrowCooldown.stop()
	else:
		$CheckConditionsTimer.start()
		$SeedGrowCooldown.start()
	lod_mode = lod_triggered

func show_symb_visuals():
	$SymbiosisVisuals.visible = true
	$FlashTween.interpolate_property($SymbiosisVisuals.material_override, "shader_param/alpha", 1.0, 0.0, 5.0)
	$FlashTween.start()
	yield(get_tree().create_timer(5),"timeout")
	$SymbiosisVisuals.visible = false
