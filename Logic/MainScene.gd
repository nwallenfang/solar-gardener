extends Control


func _ready() -> void:
	Game.main_scene_running = true
	Game.main_scene = self
	Game.UI = $UI
