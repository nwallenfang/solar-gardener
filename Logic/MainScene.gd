extends Control


func _ready() -> void:
	Game.main_scene_running = true
	Game.main_scene = self
	Game.UI = $UI
	
	
	# TODO remove this
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
