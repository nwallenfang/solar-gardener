extends KinematicBody
class_name PlayerOld

signal player_got_hurt


export var gravity_multiplier := 3.0
export var speed := 40
export var acceleration := 8
export var deceleration := 10
export(float, 0.0, 1.0, 0.05) var air_control := 0.3
export var jump_height := 12
export var jump_extra_frames:float = 0.2
export var friction := 0.1
var direction := Vector3()
var last_strong_direction := Vector3()
var input_axis := Vector2()
var velocity := Vector3()
var snap := Vector3()
var up_direction := Vector3.UP
var stop_on_slope := true
onready var floor_max_angle: float = deg2rad(45.0)
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
onready var gravity_strength = (ProjectSettings.get_setting("physics/3d/default_gravity") 
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
#	$Mesh.visible = false
	yield(get_tree(), "idle_frame")
	Game.UI.get_node("UpdateDiagnostics").connect("timeout", self, "fill_diagnostics")

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
	if movement_disabled:
		return 
		
	
	input_axis = Input.get_vector("move_backwards", "move_forward",
			"move_left", "move_right")
			
	if infinite_run:
		input_axis[0] = 1
		
	
	
	direction = get_input_direction()
	gravity_direction = gravity_direction()
	

	snap = gravity_direction #- get_floor_velocity() * delta  # moving planets?
	velocity += gravity_strength * gravity_direction * delta
	orient_player_sphere(delta)
	velocity = accelerate(velocity, direction, delta)
#	
	up_direction = -gravity_direction
	velocity = move_and_slide_with_snap(velocity, snap, up_direction, 
			stop_on_slope, 4, floor_max_angle)

var forward_dir: Vector3
func orient_player_sphere(delta: float):
	var target_up = Game.planet.global_translation.direction_to(global_translation)
	var v = target_up.cross(Vector3.UP).normalized()
	var basis = Basis.IDENTITY.rotated(v, -target_up.angle_to(Vector3.UP))

	Game.UI.set_diagnostics(["mouse_axis", mouse_axis])
	var angle_diff = transform.basis.z.cross(-target_up).cross(target_up).angle_to(basis.z)
	basis = basis.rotated(target_up, angle_diff)
	basis = basis.rotated(target_up, -mouse_axis.x * mouse_sensitivity)
#	basis = basis.rotated(target_up, mouse_axis.y * mouse_sensitivity)
	mouse_axis = Vector2()
	transform = transform.orthonormalized()
	transform.basis = basis


func get_input_direction() -> Vector3:
	direction = transform.basis.z * -input_axis.x + transform.basis.x * input_axis.y
#	direction = Vector3(-input_axis.x, 0.0, input_axis.y)
	return direction

func accelerate(old_velocity: Vector3, direction: Vector3, delta: float) -> Vector3:
	# Using only the horizontal velocity, interpolate towards the input.
	velocity = velocity * pow((1.0 - friction), delta * 60)
	velocity += speed * direction * delta
	
	
	return velocity

export var mouse_sensitivity := 0.005
export var y_limit := 90.0
var mouse_axis := Vector2()
var rot := Vector3()

# Called when there is an input event
func _input(event: InputEvent) -> void:
	# Mouse look (only if the mouse is captured).
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_axis += event.relative
#		camera_rotation()


	
func get_in_plane_velocity() -> Vector2:
	var global_vel: Vector3 = velocity
	return Vector2(global_vel.x, global_vel.z)
	
func fill_diagnostics():
#	Game.UI.set_diagnostics(["mouse_axis", mouse_axis])
	pass
