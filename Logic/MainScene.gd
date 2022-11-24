extends Control


# could be set to something like 0.75 in the Web Export for better performance
var resolution_scaling_factor = 1.0

func _input(event: InputEvent) -> void:
	if Game.game_state == Game.State.INGAME or Game.game_state == Game.State.INTRO_FLIGHT and event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Game.UI.get_node("ClickToFocus").visible = false

#func game_did_something(a, b):
#	set_process_input(false)

func _ready() -> void:
	Game.main_scene_running = true
	Game.main_scene = self
	Game.UI = $UI
#	Game.connect("changed_state", self, "game_did_something")
	get_viewport().connect("size_changed", self, "root_viewport_size_changed")
	
	if not OS.has_feature("HTML5"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	Input.use_accumulated_input = true
	
	if not OS.is_debug_build():
		Engine.target_fps = 144
	
	# custom cursors don't work properly in web builds atm :(( really sad
	# https://github.com/godotengine/godot/issues/67925
	Input.set_custom_mouse_cursor(preload("res://Assets/Sprites/cursor.png"))
	
	yield(get_tree(), "idle_frame")
	$ViewportContainer/Viewport.size = get_viewport().size * resolution_scaling_factor
	
	Events.setup()


# we want the root viewport's size change to be applied to the 3D Viewport
func root_viewport_size_changed():
	$ViewportContainer/Viewport.size = get_viewport().size * resolution_scaling_factor

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		if OS.has_feature("HTML5"):
			if not Game.game_state == Game.State.INTRO_FLIGHT and not Game.game_state == Game.State.LOADING:
				Game.game_state = Game.State.SETTINGS
