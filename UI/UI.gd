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
	if OS.is_debug_build():
		$Diagnostics.visible = true
#	get_viewport().connect("size_changed", self, "root_viewport_size_changed")
	
#	yield(get_tree(), "idle_frame")
#
#	if Game.camera != null:
#		Game.camera.set_screen_texture($ScreenViewport.get_texture())
#	else:
#		printerr("Can't set ScreenViewport texture since camera uninitialized.")


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
			$Toolbar.visible = true
			$HotkeyGuide.visible = true
			$TutorialPanel.visible = true
			if OS.is_debug_build():
				$Diagnostics.visible = true
			$"%Crosshair".visible = true
		Game.State.SETTINGS:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$SettingsUI.show_settings()
			$JournalUI.hide()
			$"%Crosshair".visible = false
			$Toolbar.visible = false
			$HotkeyGuide.visible = false
			$TutorialPanel.visible = false
			$Diagnostics.visible = false
		Game.State.JOURNAL:
			$"%Crosshair".visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$SettingsUI.hide_settings()
			$JournalUI.show()
			$Toolbar.visible = false
			$HotkeyGuide.visible = false
			$TutorialPanel.visible = false
			$Diagnostics.visible = false


## we want the root viewport's size change to be applied to the 3D Viewport
#func root_viewport_size_changed():
#	$ViewportContainer/Viewport.size = get_viewport().size
