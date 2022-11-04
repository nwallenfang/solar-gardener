extends CanvasLayer
class_name UI

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func show_settings():
	$SettingsUI.show_settings()
	
	
func hide_settings():
	Audio.play("event_pickup")
	Game.game_state = Game.State.INGAME
	$SettingsUI.hide_settings()
