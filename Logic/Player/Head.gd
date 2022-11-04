extends Spatial


#export(NodePath) var cam_path := NodePath("Camera")
#onready var cam: Camera = get_node(cam_path)

export var mouse_sensitivity := 0.005
export var y_limit := 90.0
var mouse_axis := Vector2()
var rot := Vector3()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	y_limit = deg2rad(y_limit)
#	Game.player_camera = $Camera
	
	
	yield(get_tree(), "idle_frame")
	# Find the target node
	_target = Game.player
	set_process(true)
#	set_as_toplevel(true)


func camera_rotation() -> void:
	var y_axis_factor = 2.0 * float(not Game.invert_y_axis) - 1.0  # felt like writing it convoluted but it's just 1.0 or -1.0 depending
	if Game.player.movement_disabled:
		return
	# Horizontal mouse look.
	rot.y -= mouse_axis.x * mouse_sensitivity
	# Vertical mouse look.
	rot.x = clamp(rot.x - mouse_axis.y * y_axis_factor * mouse_sensitivity, -y_limit, y_limit)
	
	get_owner().rotation.y = rot.y
	rotation.x = rot.x  
	
	mouse_axis.x = 0
	mouse_axis.y = 0


# Node that the camera will follow
var _target

# We will smoothly lerp to follow the target
# rather than follow exactly
var _target_pos : Vector3 = Vector3()


