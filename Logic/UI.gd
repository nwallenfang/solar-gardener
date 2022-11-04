extends CanvasLayer
class_name UI

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UpdateDiagnostics.start()
	Game.connect("changed_state", self, "changed_state")


func show_settings():
	$SettingsUI.show_settings()
	
	
func hide_settings():
	Audio.play("event_pickup")
	$SettingsUI.hide_settings()
	
	
func set_diagnostics(stuff):
	$"%TransformDiagnostics".text = ""
	for line in stuff:
		$"%TransformDiagnostics".text += str(line) + "\n"


func changed_state(state):
	match state:
		Game.State.INGAME:
			hide_settings()
			$"%Crosshair".visible = true
		Game.State.SETTINGS:
			show_settings()
			$"%Crosshair".visible = false

func _on_UpdateDiagnostics_timeout() -> void:
	$"%FPS".text = "FPS: %d" % Engine.get_frames_per_second()
