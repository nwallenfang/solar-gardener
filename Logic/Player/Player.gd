extends KinematicBody
class_name Player

signal player_got_hurt

export var min_sensitivity := 0.001
export var max_sensitivity := 0.015
export var y_axis_factor := 1.0
export var mouse_sensitivity := 0.005
export var y_limit := deg2rad(90.0)

export var speed := 30

export(float, 0.0, 1.0, 0.05) var air_control := 0.3
export var jump_acceleration := 950
export var jetpack_fuel := 1.0
export var unlocked_jetpack := false
export var ground_friction := 0.1
export var air_friction := 0.05
var direction := Vector3()

var input_axis := Vector2()
var velocity := Vector3()
var snap := Vector3()
var up_direction := Vector3.UP
var stop_on_slope := true
onready var floor_max_angle: float = deg2rad(45.0)
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.

export var gravity_multiplier := 3.0
onready var gravity_strength : float = (ProjectSettings.get_setting("physics/3d/default_gravity") 
		* gravity_multiplier)

var movement_disabled = false
var has_jumped = false
var jump_action_released_after_jump := false

onready var pickup_point : Spatial = $"%PickupPoint"

func _ready():
	Game.player = self
	$Mesh.visible = false

var gravity_effect_max_dist = 40  # TODO this should be changed since it depends on planet size
func calc_gravity_direction() -> Vector3:
	if Game.planet != null:
		var dist_to_planet = global_translation.distance_to(Game.planet.global_translation)
		if dist_to_planet > gravity_effect_max_dist:
			return Vector3(0.0, -1.0, 0.0).normalized()
		return global_translation.direction_to(Game.planet.global_translation)
		
	return Vector3(0.0, -1.0, 0.0).normalized()


# Called every physics tick. 'delta' is constant
var gravity_direction
const footstep_thresh = 0.2
func _physics_process(delta) -> void:
	if Game.game_state == Game.State.LOADING or Game.game_state == Game.State.INTRO_FLIGHT or Game.game_state == Game.State.WARPING:
		return 
		
	input_axis = Input.get_vector("move_backwards", "move_forward",
			"move_left", "move_right")
	var trigger_jump : bool = is_on_floor() and Input.is_action_just_pressed("jump") and !has_jumped
	if not jump_action_released_after_jump:
		jump_action_released_after_jump = Input.is_action_just_released("jump")
	var trigger_jetpack = unlocked_jetpack and (not is_on_floor()) and Input.is_action_pressed("jump") and jump_action_released_after_jump and has_jumped and (jetpack_fuel>0.0)
	
	if trigger_jetpack and not "jetpack" in Audio.playing:
		Audio.fade_in("jetpack", 0.1, true)
	if not trigger_jetpack and "jetpack" in Audio.playing:
		Audio.fade_out("jetpack", 0.1)
	
	if movement_disabled or Game.game_state != Game.State.INGAME:
		input_axis = Vector2.ZERO
		mouse_axis = Vector2.ZERO
		trigger_jump = false
	
	direction = get_input_direction()
	gravity_direction = calc_gravity_direction()
	
	if trigger_jetpack:
#		print(jetpack_fuel)
		velocity += jump_acceleration * delta * transform.basis.y * 0.04
		jetpack_fuel -= delta * .7
	$JetpackLight.visible = trigger_jetpack
	$JetpackFlames/Particles.emitting = trigger_jetpack
	if trigger_jump:
		# init jump
		snap = Vector3.ZERO
		# player basis y is the player's up direction
		velocity += jump_acceleration * delta * transform.basis.y
		has_jumped = true
		jump_action_released_after_jump = false
		Audio.stop_footsteps()
	elif is_on_floor():
		if has_jumped:
			# end jump
			# TODO add contact sound effect
			has_jumped = false
			jetpack_fuel = 1.0
			var prefix: String = Game.planet.music_prefix		
			# dirty (heh) last minute hack
#			if prefix == "dirt":
#				prefix = "sand"
#			elif prefix == "sand":
#				prefix = "dirt"
			Audio.play_random_step(prefix)
		snap = gravity_direction
	
	var planet_gravity_modifier : float = Game.planet.gravity_modifier
	if direction.length() > 0.1 or not is_on_floor():
		velocity += gravity_strength * gravity_direction * delta * planet_gravity_modifier
	orient_player_sphere(delta)
	velocity = accelerate(velocity, direction, delta)
#	
	up_direction = -gravity_direction
	velocity = move_and_slide_with_snap(velocity, snap, up_direction, 
			stop_on_slope, 4, floor_max_angle)
			
	if direction.length() > footstep_thresh and is_on_floor():
#		if Game.player_is_in_shed:
#			Audio.start_footsteps("wood")
#		else:
		var prefix: String = Game.planet.music_prefix
		
		# dirty (heh) last minute hack
#		if prefix == "dirt":
#			prefix = "sand"
#		elif prefix == "sand":
#			prefix = "dirt"
		Audio.start_footsteps(prefix)
	else:
		Audio.stop_footsteps()


func update_look_direction():
	look_direction = -transform.basis.z
	target_look = -transform.basis.z
	mouse_axis = Vector2()
	last_target_up = Vector3.ZERO

# SHED HARD CODE DIRTY
var shed:Spatial
var shed_factor := 0.0


var forward_dir: Vector3
var last_strong_direction: Vector3
var look_direction := -transform.basis.z
var last_target_up := Vector3.ZERO
var target_look := -transform.basis.z
func orient_player_sphere(delta: float):
	var target_up = Game.planet.global_translation.direction_to(global_translation)
	if shed_factor != 0.0: # SHED DIRTY
		target_up = lerp(target_up, Game.planet.global_translation.direction_to(shed.global_translation), shed_factor).normalized()
	if last_target_up == Vector3.ZERO:
		last_target_up = target_up
	var v = target_up.cross(Vector3.UP).normalized()
	var basis = Basis.IDENTITY.rotated(v, -target_up.angle_to(Vector3.UP))

	if target_up != last_target_up:
		var turn_axis : Vector3 = target_up.cross(last_target_up).normalized()
		var turn_angle : float = last_target_up.angle_to(target_up)
		look_direction = look_direction.rotated(-turn_axis.normalized(), turn_angle)
	look_direction = look_direction.rotated(target_up, -mouse_axis.x * mouse_sensitivity)
	target_look = look_direction.cross(-target_up).cross(target_up)
#	Game.UI.set_diagnostics(["mouse_axis", mouse_axis])
	$Head.rotation.x = clamp($Head.rotation.x - mouse_axis.y * y_axis_factor * mouse_sensitivity, -y_limit, y_limit)
	mouse_axis = Vector2() # Reset Mouse Input

	transform.basis = Basis(-target_up.cross(target_look), target_up, -target_look)

	transform = transform.orthonormalized()
	var test_t := global_transform
	test_t.origin = Game.planet.to_local(global_translation)
	test_t = test_t.rotated(Game.planet.rotation_axis, delta * Game.planet.y_rotation_speed)
	test_t.origin = Game.planet.to_global(test_t.origin)
	global_transform = test_t
	last_target_up = target_up
	
	look_direction = -transform.basis.z



func get_input_direction() -> Vector3:
	direction = transform.basis.z * -input_axis.x + transform.basis.x * input_axis.y
#	direction = Vector3(-input_axis.x, 0.0, input_axis.y)
	return direction

func accelerate(old_velocity: Vector3, direction: Vector3, delta: float) -> Vector3:
	# Using only the horizontal velocity, interpolate towards the input.
	# apply ground friction if on floor
	if is_on_floor():
		velocity = velocity * pow((1.0 - ground_friction), delta * 60)
	else:
		velocity = velocity * pow((1.0 - air_friction), delta * 60)
	velocity += speed * direction * delta
	
	return velocity


var mouse_axis := Vector2()
#var previous_position := Vector2()
# Called when there is an input event
func _input(event: InputEvent) -> void:
	# Mouse look (only if the mouse is captured).
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not event.is_echo():
		# fix first frame
		mouse_axis += event.relative
#		camera_rotation()
#		previous_position = event.position
		get_tree().set_input_as_handled()


	
func get_in_plane_velocity() -> Vector2:
	var global_vel: Vector3 = velocity
	return Vector2(global_vel.x, global_vel.z)
