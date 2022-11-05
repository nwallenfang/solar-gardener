extends CanvasLayer
class_name UI

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

onready var crosshair : Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	crosshair = $"%Crosshair"
	Game.connect("changed_state", self, "changed_state")


func set_diagnostics(stuff):
	$"%TransformDiagnostics".text = ""
	for line in stuff:
		$"%TransformDiagnostics".text += str(line) + "\n"


func changed_state(state, prev_state):
	match state:
		Game.State.INGAME:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$SettingsUI.hide_settings()
			$JournalUI.hide()
			$"%Crosshair".visible = true
		Game.State.SETTINGS:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$SettingsUI.show_settings()
			$JournalUI.hide()
			$"%Crosshair".visible = false
		Game.State.JOURNAL:
			$"%Crosshair".visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$SettingsUI.hide_settings()
			$JournalUI.show()
