extends KinematicBody
class_name Player

signal player_got_hurt



export var speed := 30

export(float, 0.0, 1.0, 0.05) var air_control := 0.3
export var jump_acceleration := 1000
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
onready var gravity_strength = (ProjectSettings.get_setting("physics/3d/default_gravity") 
		* gravity_multiplier)


var movement_disabled = false
var has_jumped = false

func _ready():
	Game.player = self
	$Mesh.visible = false


var gravity_effect_max_dist = 40  # TODO this should be changed since it depends on planet size
func gravity_direction() -> Vector3:
	if Game.planet != null:
		var dist_to_planet = global_translation.distance_to(Game.planet.global_translation)
		if dist_to_planet > gravity_effect_max_dist:
			return Vector3(0.0, -1.0, 0.0).normalized()
		return global_translation.direction_to(Game.planet.global_translation)
		
	return Vector3(0.0, -1.0, 0.0).normalized()


# Called every physics tick. 'delta' is constant
var gravity_direction
func _physics_process(delta) -> void:
	if movement_disabled or Game.game_state != Game.State.INGAME:
		return 
		
	input_axis = Input.get_vector("move_backwards", "move_forward",
			"move_left", "move_right")
	
	direction = get_input_direction()
	gravity_direction = gravity_direction()
	
	if is_on_floor() and Input.is_action_just_pressed("jump") and !has_jumped:
		# init jump
		snap = Vector3.ZERO
		# player basis y is the player's up direction
		velocity += jump_acceleration * delta * transform.basis.y
		has_jumped = true
	elif is_on_floor():
		if has_jumped:
			# end jump
			has_jumped = false
		snap = gravity_direction

	velocity += gravity_strength * gravity_direction * delta
	orient_player_sphere(delta)
	velocity = accelerate(velocity, direction, delta)
#	
	up_direction = -gravity_direction
	velocity = move_and_slide_with_snap(velocity, snap, up_direction, 
			stop_on_slope, 4, floor_max_angle)


func update_look_direction():
	look_direction = -transform.basis.z
	target_look = -transform.basis.z
	mouse_axis = Vector2()
	last_target_up = Vector3.ZERO

var forward_dir: Vector3
var last_strong_direction: Vector3
var look_direction := -transform.basis.z
var last_target_up := Vector3.ZERO
var target_look := -transform.basis.z
func orient_player_sphere(delta: float):
	var target_up = Game.planet.global_translation.direction_to(global_translation)
	if last_target_up == Vector3.ZERO:
		last_target_up = target_up
	var v = target_up.cross(Vector3.UP).normalized()
	var basis = Basis.IDENTITY.rotated(v, -target_up.angle_to(Vector3.UP))

	if target_up != last_target_up:
		var turn_axis : Vector3 = target_up.cross(last_target_up).normalized()
		var turn_angle : float = last_target_up.angle_to(target_up)
		look_direction = look_direction.rotated(-turn_axis, turn_angle)
	look_direction = look_direction.rotated(target_up, -mouse_axis.x * mouse_sensitivity)
	target_look = look_direction.cross(-target_up).cross(target_up)

	$Head.rotation.x = clamp($Head.rotation.x - mouse_axis.y * y_axis_factor * mouse_sensitivity, -y_limit, y_limit)

	mouse_axis = Vector2() # Reset Mouse Input

	transform.basis = Basis(-target_up.cross(target_look), target_up, -target_look)
	transform = transform.orthonormalized()

	last_target_up = target_up



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

export var y_axis_factor := 1.0
export var mouse_sensitivity := 0.005
export var y_limit := deg2rad(90.0)
var mouse_axis := Vector2()

# Called when there is an input event
func _input(event: InputEvent) -> void:
	# Mouse look (only if the mouse is captured).
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_axis += event.relative
#		camera_rotation()


	
func get_in_plane_velocity() -> Vector2:
	var global_vel: Vector3 = velocity
	return Vector2(global_vel.x, global_vel.z)
