extends KinematicBody
class_name Player

signal player_got_hurt


export var gravity_multiplier := 3.0
export var speed := 10
export var acceleration := 8
export var deceleration := 10
export(float, 0.0, 1.0, 0.05) var air_control := 0.3
export var jump_height := 12
export var jump_extra_frames:float = 0.2
var direction := Vector3()
var input_axis := Vector2()
var velocity := Vector3()
var snap := Vector3()
var up_direction := Vector3.UP
var stop_on_slope := true
onready var floor_max_angle: float = deg2rad(45.0)
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
onready var gravity = (ProjectSettings.get_setting("physics/3d/default_gravity") 
		* gravity_multiplier)

var knockback := Vector3.ZERO

var double_jump = false
var used_second_jump = false
var inverted_controls = false
var invincible = false
var infinite_run = false


var movement_disabled = false
var default_scale

var extra_frame_idx = 0
var has_jumped = false

func _ready():
	Game.player = self
	default_scale = self.scale
	$Mesh.visible = false


# Called every physics tick. 'delta' is constant
func _physics_process(delta) -> void:
	if movement_disabled:
		return 
		
	
	input_axis = Input.get_vector("move_backwards", "move_forward",
			"move_left", "move_right")
			
	if infinite_run:
		input_axis[0] = 1
		
	
	
	direction_input()
	
	if is_on_floor():
		has_jumped = false
		extra_frame_idx = 0
		snap = -get_floor_normal() - get_floor_velocity() * delta
		
		# Workaround for sliding down after jump on slope
		if velocity.y < 0:
			velocity.y = 0
		
		if !has_jumped and Input.is_action_just_pressed("jump"):
			snap = Vector3.ZERO
			velocity.y = jump_height
			has_jumped = true
			
		used_second_jump = false
	elif extra_frame_idx < jump_extra_frames:
		if !has_jumped and Input.is_action_just_pressed("jump"):
			snap = Vector3.ZERO
			velocity.y = jump_height
			has_jumped = true
		extra_frame_idx += delta
		velocity.y -= gravity * delta
	else:
		has_jumped = false
		# Workaround for 'vertical bump' when going off platform
		if snap != Vector3.ZERO && velocity.y != 0:
			velocity.y = 0
		
		snap = Vector3.ZERO
		
		velocity.y -= gravity * delta
		
		if Input.is_action_just_pressed("jump") and double_jump and !used_second_jump:
			velocity.y = jump_height
			used_second_jump = true
			
	if knockback != Vector3.ZERO:
		snap = Vector3.ZERO
		velocity += knockback
		knockback = Vector3.ZERO
	
	accelerate(delta)
	
	
	velocity = move_and_slide_with_snap(velocity, snap, up_direction, 
			stop_on_slope, 4, floor_max_angle)

func direction_input() -> void:
	direction = Vector3()
	var aim: Basis = get_global_transform().basis
	direction = aim.z * -input_axis.x + aim.x * input_axis.y


func accelerate(delta: float) -> void:
	# Using only the horizontal velocity, interpolate towards the input.
	var temp_vel := velocity
	temp_vel.y = 0
	
	var temp_accel: float
	var target: Vector3 = direction * speed
	
	if direction.dot(temp_vel) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
	
	if not is_on_floor():
		temp_accel *= air_control
	
	temp_vel = temp_vel.linear_interpolate(target, temp_accel * delta)
	
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z

	
func get_in_plane_velocity() -> Vector2:
	var global_vel: Vector3 = velocity
	return Vector2(global_vel.x, global_vel.z)
