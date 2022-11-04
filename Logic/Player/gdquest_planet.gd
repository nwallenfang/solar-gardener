extends RigidBody
class_name Player

func _ready():
	Game.player = self
	$Mesh.visible = false

export var jump_initial_impulse := 40.0
export var move_speed := 2.0
export var rotation_speed := 60.0

var movement_disabled = false

onready var model = $Head
var local_gravity: Vector3
var should_reset = false

# von Nils
var velocity := Vector3(0.0, 0.0, 0.0)
export var speed := 10
export var acceleration := 8
export var deceleration := 10
export(float, 0.0, 1.0, 0.05) var air_control := 0.3


var move_direction: Vector3
var last_strong_direction: Vector3
func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	if should_reset:
		# start position
		pass

	local_gravity = state.total_gravity.normalized()
	print(local_gravity)
	# last strong direction??
	if move_direction.length() > 0.2:
		last_strong_direction = move_direction.normalized()

	# this used to be get_model_oriented_input
	# replaced by our function direction_input
	move_direction = direction_input()
	orient_character_to_direction(last_strong_direction, state.step)

	if is_jumping(state):
		apply_central_impulse(-local_gravity * jump_initial_impulse)
	if is_on_floor(state) and true:
		print("force: ", move_direction * move_speed)
		apply_central_impulse(move_direction * move_speed)		
#		state.linear_velocity = update_velocity(state.linear_velocity, state.step, state)
	# TODO something missing here or this line was only for visual purposes (<- likely)
#	model.velocity = state.linear_velocity

func get_model_oriented_input() -> Vector3:
	var input_left_right = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var input_forward = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backwards")

#	var raw_input = Vector2(input_left_right, input_forward)

	var input = Vector3(input_left_right, 0.0, input_forward)

	# here there was some quadratic transformation for joystick input
	# input.x = raw_input.x * sqrt(1.0 - raw_input.y * raw_input.y)

	input = model.transform.basis.xform(input)
	return input

func orient_character_to_direction(direction: Vector3, delta: float) -> void:
	var left_axis := -local_gravity.cross(direction)
	var rotation_basis := Basis(left_axis, -local_gravity, direction).orthonormalized()

	# probably not needed for us but idk
#	model.transform.basis = Basis(model.transform.basis.get_rotation_quat().slerp(rotation_basis, delta * rotation_speed))

func is_on_floor(state) -> bool:
	for contact in state.get_contact_count():
		var contact_normal = state.get_contact_local_normal(contact)
		# if contact is below us we are on the floor
		if contact_normal.dot(-local_gravity) > 0.5:
			return true
	return false
	
func is_jumping(state) -> bool:
	return Input.is_action_just_pressed("jump")


## Nils stuff
func update_velocity(prev_velocity: Vector3, delta: float, state) -> Vector3:
	# Using only the horizontal velocity, interpolate towards the input.
	var temp_vel := prev_velocity
	temp_vel.y = 0
	var direction = model.get_global_transform().basis.z
	var temp_accel: float
	var target: Vector3 = direction * speed
	
	if direction.dot(temp_vel) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
	
	if not is_on_floor(state):
		temp_accel *= air_control
	
	temp_vel = temp_vel.linear_interpolate(target, temp_accel * delta)
	
#	velocity.x = temp_vel.x
#	velocity.z = temp_vel.z
	
	return temp_vel
	
func direction_input() -> Vector3:
	var input_axis = Input.get_vector("move_backwards", "move_forward",
			"move_left", "move_right")
	var direction = Vector3()
	var aim: Basis = get_global_transform().basis
	direction = aim.z * -input_axis.x + aim.x * input_axis.y
	return direction
