extends Spatial
class_name Planet

export var planet_name : String
onready var analyse_name : String = "Soil Type"
var analyse_speed_factor := .3
func on_analyse():
	analyse_speed_factor = 1.5

export(Color) var dirt_pile_color : Color

export var soil_type : int
export var sun : bool
export var moist : bool
export var nutrients : bool

var player_on_planet := false

# degrees per second
export var rotation_axis: Vector3 = Vector3.UP
export var y_rotation_speed = deg2rad(3.5)
export var max_plants : int

# for music and footsteps
export var music_prefix := "sand"

export var is_obsidian := false

export var gravity_modifier := 1.0

var planet_growth_stage := 0  # for the music or general planet progression
var planet_light : PlanetLight

var plant_list := []

var lod_items := []

func add_plant(plant):
	add_child_with_light(plant)
	plant_list.append(plant)
	add_to_lod_list(plant)

func configure_light(n: Node):
	for mi in Utility.get_all_mesh_instance_children(n):
		(mi as MeshInstance).layers = planet_light.mask_value

func add_to_lod_list(n: Node):
	lod_items.append(n)

func add_child_with_light(n: Node):
	add_child(n)
	configure_light(n)


const PLANET_LIGHT = preload("res://Effects/PlanetLight.tscn")
func setup():
	var planet_id = Game.planet_list.size()
	Game.planet_list.append(self)
	planet_light = PLANET_LIGHT.instance()
	Game.world.add_child(planet_light)
	planet_light.setup(planet_id, self)
	configure_light(self)

func growth_stage_reached(growth_stage: int):
	if growth_stage == 4:
		return
	if music_prefix == "obsidian":
		return
	if growth_stage > planet_growth_stage:
		planet_growth_stage = growth_stage
		
		# trigger next music if on this planet
		if Game.planet == self and Game.game_state == Game.State.INGAME:
			var used_prefix = music_prefix

			var music_next = "music_%s_%d" % [used_prefix, growth_stage]
			var music_prev = "music_%s_%d" % [used_prefix, growth_stage-1]
			if growth_stage == 1:
				Audio.cross_fade("music_ambience", music_next)
			else:  # 2 or 3
				Audio.cross_fade(music_prev, music_next)
			
func fade_out():
	if music_prefix == "obsidian":
		Audio.fade_out("music_obsidian_0")
		return
	var used_prefix = music_prefix

	var music = "music_%s_%d" % [used_prefix, planet_growth_stage]
	if planet_growth_stage > 0:
		Audio.fade_out(music)
	else:
		Audio.fade_out("music_ambience")
	
func fade_in():
	if music_prefix == "obsidian":
		Audio.fade_in("music_obsidian_0", 1.0, true)
		return
	var used_prefix = music_prefix

	if planet_growth_stage > 0:
		var music = "music_%s_%d" % [used_prefix, planet_growth_stage]
		Audio.fade_in(music, 1.0, true)
	else:
		Audio.fade_in("music_ambience", 1.0, true)


func get_current_music_name() -> String:
	if planet_growth_stage > 0:
		var used_prefix = music_prefix
		var music = "music_%s_%d" % [used_prefix, planet_growth_stage]
		
		return music
	else:
		return "music_ambience"

func set_player_is_on_planet(b: bool):
	player_on_planet = b
	$PlanetHopArea.set_deferred("monitoring", not player_on_planet)
	$PlanetHopArea.set_deferred("monitorable", not player_on_planet)
	$PlanetHopArea/CollisionShape.disabled = player_on_planet
	planet_light.set_player_is_on_planet(player_on_planet)
	trigger_lod(not player_on_planet)

var render_multi_mesh := true
func trigger_lod(lod: bool):
	for lod_item in lod_items:
		if is_instance_valid(lod_item):
			lod_item = lod_item as Node
			if lod_item.has_method("on_lod"):
				lod_item.call("on_lod", lod)
	if has_node("MultiMesh"):
		$MultiMesh.visible = (not lod) and render_multi_mesh

func get_count_of_plant_type(plant_name: String) -> int:
	var count := 0
	for plant in plant_list:
		if plant.profile.name == plant_name:
			count += 1
	return count

func _physics_process(delta: float) -> void:
	if Game.game_state != Game.State.LOADING:
		self.global_rotate(rotation_axis, delta * y_rotation_speed)

func get_analyse_info_text() -> String:
	return ""

var has_been_grab_rooted := false
func try_grabroot_effect(pos: Vector3):
	if Game.planet != self:
		return
	if Events.get_event_from_key("journal_opened").execute_count == 0 or Events.get_event_from_key("seeds_harvested").execute_count == 0:
		return
	if not has_been_grab_rooted:
		while true:
			if Utility.start_reliable_test(pos):
				yield(get_tree().create_timer(.1), "timeout")
				break
			else:
				yield(get_tree(),"idle_frame")
		if Utility.get_reliable_result():
			has_been_grab_rooted = true
			if has_node("GrabrootGrabber"):
				var grabber : Spatial = get_node("GrabrootGrabber")
				grabber.emerge(pos)
				Game.camera.screen_shake()
