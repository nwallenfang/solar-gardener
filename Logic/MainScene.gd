extends Control


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		set_process_input(false)

func _ready() -> void:
	Game.main_scene_running = true
	Game.main_scene = self
	Game.UI = $UI
	
	if not OS.has_feature("HTML5"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# custom cursors don't work in web builds atm :(( really sad
	# https://github.com/godotengine/godot/issues/67925
	Input.set_custom_mouse_cursor(preload("res://Assets/Sprites/cursor.png"))
