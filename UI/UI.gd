extends CanvasLayer
class_name UI

enum INFO {
	MORE_SEEDS,
	PLANT_PREFERENCE,
	PLANT_UNLOCKED,
	PLANT_SCANNED,
}

const DIAGNOSE_ON_WEB := true # set to true if diagnostics should show in web export
func _ready() -> void:
	Game.connect("changed_state", self, "changed_state")
	Game.multitool.connect("switched_to", self, "switched_to_tool")
	if OS.is_debug_build() or DIAGNOSE_ON_WEB:
		$Diagnostics.visible = true


func set_diagnostics(stuff):
	$"%TransformDiagnostics".text = ""
	for line in stuff:
		$"%TransformDiagnostics".text += str(line) + "\n"

func switched_to_tool(new_tool: int):
	$Toolbar.switch_to(new_tool)
	if new_tool in Game.multitool.tooltips:
		var tooltip = Game.multitool.tooltips[new_tool]
		$"%MultitoolA".text = tooltip[0]
		$"%MultitoolC".text = tooltip[1]
		$"%MultitoolC".visible = true
		$"%MultitoolA".visible = true
		if new_tool == Game.multitool.TOOL.GROW and Events.get_event_from_key("remove_unlocked").execute_count > 0:
			$"%MultitoolC2".visible = true
			$"%MultitoolA2".visible = true
		else:
			$"%MultitoolC2".visible = false
			$"%MultitoolA2".visible = false

	else:
		$"%MultitoolC".visible = false
		$"%MultitoolA".visible = false
		$"%MultitoolC2".visible = false
		$"%MultitoolA2".visible = false



var mode = null
func _input(event):
	if mode != null:
		Input.set_mouse_mode(mode)
		yield(get_tree(),"idle_frame")
		Input.set_mouse_mode(mode)
		yield(get_tree(),"idle_frame")
		Input.set_mouse_mode(mode)
		#mode = null

func changed_state(state, prev_state):
	match state:
		Game.State.INGAME:
			mode=Input.MOUSE_MODE_CAPTURED#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$SettingsUI.hide_settings()
			$JournalAndGuideUI.hide()
			$Toolbar.visible = true
			$HotkeyGuide.visible = true
			$TutorialPanel.visible = true
			if OS.is_debug_build() or DIAGNOSE_ON_WEB:
				$Diagnostics.visible = true
			$"%Crosshair".visible = true
			$GardenerNote.visible = false
			$SkipCutsceneLabel.visible = false
		Game.State.SETTINGS:
			mode = Input.MOUSE_MODE_VISIBLE#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$SettingsUI.show_settings()
			$JournalAndGuideUI.hide()
			$"%Crosshair".visible = false
			$Toolbar.visible = false
			$HotkeyGuide.visible = false
			$TutorialPanel.visible = false
#			$Diagnostics.visible = false
			$GardenerNote.visible = false
		Game.State.JOURNAL:
			Events.trigger("journal_opened")
			$"%Crosshair".visible = false
			mode = Input.MOUSE_MODE_VISIBLE#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$SettingsUI.hide_settings()
			$JournalAndGuideUI.show()
			$Toolbar.visible = false
			$HotkeyGuide.visible = false
			$TutorialPanel.visible = false
#			$Diagnostics.visible = false
			$GardenerNote.visible = false
		Game.State.READING_NOTE:
			$"%Crosshair".visible = false
			mode = Input.MOUSE_MODE_VISIBLE#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$SettingsUI.hide_settings()
			$JournalAndGuideUI.hide()
			$Toolbar.visible = false
			$HotkeyGuide.visible = false
			$TutorialPanel.visible = false
#			$Diagnostics.visible = false
			$GardenerNote.visible = true
		Game.State.INTRO_FLIGHT:
			$"%Crosshair".visible = false
			$HotkeyGuide.visible = false
			$TutorialPanel.visible = false
			$Toolbar.visible = false
			$SkipCutsceneLabel.visible = true

func set_note_text(text: String):
	$GardenerNote.set_text(text)


func set_blackscreen_alpha(alpha_in_percent: float): #should start with .99 alpha
	$BlackScreen.modulate.a = alpha_in_percent

func set_loading_bar(progress_in_percent: float): #Optional
	$"%LoadingLabel".text = "Loading " + str(progress_in_percent*100.0) + "%"

func show_line(text: String, duration: float, another_one_coming:=false):
	$DialogUI.visible = true
	$DialogUI.show_dialogline(text, duration, another_one_coming)

	
var showing_right_now = false
var tutorial_queue = []
func show_next_message():
	showing_right_now = true
	var msg = tutorial_queue.pop_front()
	# TODO fade in
#	if Game.game_state == Game.State.INGAME:  
#		# if not INGAME it will be set visible from changed_state
#		$TutorialPanel.visible = true
	$TutorialPanel.show_tutorial_message(msg["title"], msg["text"])

	yield(get_tree().create_timer(msg["duration"]), "timeout")
	
	# TODO fade out 
	if tutorial_queue.empty():
		$TutorialPanel.hide_message()
		showing_right_now = false
	else:
		show_next_message()
		
func add_tutorial_message(title: String, text: String, duration:=10.0):
	var msg = {"title":title, "text":text, "duration":duration}
	tutorial_queue.append(msg)
	if not showing_right_now:
		show_next_message()
		
func show_info_line(title, type):
	$DialogUI.push_infoline(title, type)

func show_info_line_in_x_seconds(title, type, delay:float):
	yield(get_tree().create_timer(delay), "timeout")
	$DialogUI.push_infoline(title, type)


func skip_button_held():
	$"%SkipCutsceneText".rect_scale = Vector2(1.2, 1.2)
	
func skip_button_released():
	$"%SkipCutsceneText".rect_scale = Vector2(1.0, 1.0)
