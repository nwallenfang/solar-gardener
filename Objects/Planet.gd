extends Spatial
class_name Planet

export var planet_name : String
onready var analyse_name : String = planet_name
var analyse_speed_factor := .3

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
	if growth_stage > planet_growth_stage:
		planet_growth_stage = growth_stage
		
		# trigger next music if on this planet
		if Game.planet == self:
			var used_prefix = music_prefix
			if used_prefix == "dirt":
				used_prefix = "sand"
			if used_prefix != "sand":
				used_prefix = "placeholder"
			
			var music_next = "music_%s_%d" % [used_prefix, growth_stage]
			var music_prev = "music_%s_%d" % [used_prefix, growth_stage-1]
			if growth_stage == 1:
				fade_in()
			else:  # 2 or 3
				
				Audio.cross_fade(music_prev, music_next)
			
func fade_out():
	var used_prefix = music_prefix
	if used_prefix == "dirt":
		used_prefix = "sand"
	if used_prefix != "sand":
		used_prefix = "placeholder"
	var music = "music_%s_%d" % [used_prefix, planet_growth_stage]
	Audio.fade_out(music)
	
func fade_in():
	var used_prefix = music_prefix
	if used_prefix == "dirt":
		used_prefix = "sand"
	if used_prefix != "sand":
		used_prefix = "placeholder"
	if planet_growth_stage > 0:
		var music = "music_%s_%d" % [used_prefix, planet_growth_stage]
		Audio.fade_in(music)

func get_current_music_name() -> String:
	var used_prefix = music_prefix
	if used_prefix == "dirt":
		used_prefix = "sand"
	if used_prefix != "sand":
		used_prefix = "placeholder"
	var music = "music_%s_%d" % [used_prefix, planet_growth_stage]
	
	return music

func set_player_is_on_planet(b: bool):
	player_on_planet = b
	$PlanetHopArea.set_deferred("monitoring", not player_on_planet)
	$PlanetHopArea.set_deferred("monitorable", not player_on_planet)
	$PlanetHopArea/CollisionShape.disabled = player_on_planet
	planet_light.set_player_is_on_planet(player_on_planet)
	for lod_item in lod_items:
		if is_instance_valid(lod_item):
			lod_item = lod_item as Node
			if lod_item.has_method("on_lod"):
				lod_item.call_deferred("on_lod", not player_on_planet)

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
	if not has_been_grab_rooted:
		if Utility.test_planting_position(pos):
			has_been_grab_rooted = true
			if has_node("GrabrootGrabber"):
				get_node("GrabrootGrabber").emerge(pos)
