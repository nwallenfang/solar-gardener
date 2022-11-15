extends CanvasLayer
class_name UI

func _ready() -> void:
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
			$GardenerNote.visible = false
		Game.State.SETTINGS:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$SettingsUI.show_settings()
			$JournalUI.hide()
			$"%Crosshair".visible = false
			$Toolbar.visible = false
			$HotkeyGuide.visible = false
			$TutorialPanel.visible = false
			$Diagnostics.visible = false
			$GardenerNote.visible = false
		Game.State.JOURNAL:
			$"%Crosshair".visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$SettingsUI.hide_settings()
			$JournalUI.show()
			$Toolbar.visible = false
			$HotkeyGuide.visible = false
			$TutorialPanel.visible = false
			$Diagnostics.visible = false
			$GardenerNote.visible = false
		Game.State.READING_NOTE:
			$"%Crosshair".visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$SettingsUI.hide_settings()
			$JournalUI.hide()
			$Toolbar.visible = false
			$HotkeyGuide.visible = false
			$TutorialPanel.visible = false
			$Diagnostics.visible = false
			
			$GardenerNote.visible = true


## we want the root viewport's size change to be applied to the 3D Viewport
#func root_viewport_size_changed():
#	$ViewportContainer/Viewport.size = get_viewport().size

func set_note_text(text: String):
	$GardenerNote.set_text(text)


func set_blackscreen_alpha(alpha_in_percent: float): #should start with .99 alpha
	$BlackScreen.modulate.a = alpha_in_percent

func set_loading_bar(progress_in_percent: float): #Optional
	$"%LoadingLabel".text = "Loading " + str(progress_in_percent*100.0) + "%"

func show_line(text: String, duration: float, another_one_coming:=false):
	$SubtitleUI.visible = true
	# TODO play show animation
	$"%SubtitleText".text = text
	# TODO play hide animation
	# TODO if another one is coming up the text shouldn't fade out completely
	# or smth
	yield(get_tree().create_timer(duration), "timeout")
	$SubtitleUI.visible = false
	
	
func show_tutorial_message(title: String, text: String):
	# TODO fade in
	if Game.game_state == Game.State.INGAME:  
		# if not INGAME it will be set visible from changed_state
		$TutorialPanel.visible = true
	$TutorialPanel.show_tutorial_message(title, text)
	# TODO fade out when the goal is reached
#	$TutorialPanel.visible = false
