extends Node

const MODELS_FOLDER = "res://Assets/Models/"
const EFFECTS_FOLDER = "res://Plants/Effects/"

enum State {
	INGAME,
	SETTINGS,  # not paused
	JOURNAL,
	WARPING,
	READING_NOTE,
	LOADING,
	INTRO_FLIGHT,
	UPGRADING,
}

var game_state = State.LOADING setget set_game_state
var intro_done := false
# is set from MainScene, if this is false, a subscene is running individually for testing,
# if this is true game is running normally
var main_scene_running = false
var main_scene = null
# is set when main_scene_running
var UI: UI = null
var journal: JournalUI = null
var player : Player = null
var player_raycast: PlayerRayCast
var multitool: Multitool
var camera: PlayerCamera
var crosshair: Crosshair
var world: Spatial
var sun: Spatial
var hologram: Hologram
# current planet
var planet: Planet = null
var invert_y_axis = false

var planet_list := []
var coming_out_of_journal = false

var cheat_lod := false

# progresses
var number_of_ambers := 0 setget set_number_of_ambers
var number_of_logs := 0 setget set_number_of_logs
var number_of_max_lv := 0 setget set_number_of_max_lv

# move down
func set_number_of_ambers(number):
	number_of_ambers = number
	UI.get_node("JournalAndGuideUI").set_progress_amber(number)
	
func set_number_of_logs(number):
	number_of_logs = number
	UI.get_node("JournalAndGuideUI").set_progress_logs(number)
	
func set_number_of_max_lv(number):
	number_of_max_lv = number
	UI.get_node("JournalAndGuideUI").set_progress_max(number)

func _process(delta: float) -> void:
	var mode := ""
	match Input.mouse_mode:
		Input.MOUSE_MODE_CAPTURED:
			mode = "captured"
		Input.MOUSE_MODE_VISIBLE:
			mode = "free"
			# when running on HTML5 the Settings action (ESC) can't be triggered
			# since that's the hotkey for leaving the mouse capture mode.
			# So we open the settings as soon as the mouse mode changes for no reason
			# (no journal/node mode)
			if is_ingame() and OS.has_feature("HTML5") and intro_done and $SettingsOpenCooldown.is_stopped():
				set_game_state(State.SETTINGS)
	UI.set_diagnostics(["settings blocked: " + str(not $SettingsOpenCooldown.is_stopped())])
	if Input.is_action_just_pressed("open_settings"):  # show/hide settings UI
		if main_scene_running:
			if game_state == State.INGAME:
				$SettingsOpenCooldown.start(0.4)
				self.game_state = State.SETTINGS
			elif game_state == State.SETTINGS:
				# this is only the correct if you can only enter settings from ingame!!
				self.game_state = State.INGAME
	if Input.is_action_just_pressed("open_journal"):
		$SettingsOpenCooldown.start(0.4)
		if game_state == State.INGAME:
			self.game_state = State.JOURNAL
		elif game_state == State.JOURNAL:
			self.game_state = State.INGAME
			
	if Input.is_action_just_pressed("give_seeds"):
		print("gib tzieds")
		PlantData.give_seeds("Grabroot", 10, false)
		PlantData.give_seeds("Greatcap", 10, false)
		PlantData.give_seeds("Hidden Lotus", 10, false)
		PlantData.give_seeds("Fractalrose", 10, false)
		
	if Input.is_action_just_pressed("make_pref_known"):
		print("pref known")
		UI.get_node("JournalAndGuideUI").unlock_journal()
		Game.multitool.activate_tool(Game.multitool.TOOL.GROW)
		Game.multitool.activate_tool(Game.multitool.TOOL.PLANT)
		Game.multitool.activate_tool(Game.multitool.TOOL.HOPPER)
		journal.discover_and_scan_all()
#		UI.get_node("JournalAndGuideUI/JournalUI").make_preference_known("Grabroot", PlantData.PREFERENCES["Hates Sun"])
#		UI.get_node("JournalAndGuideUI/JournalUI").make_preference_known("Grabroot", PlantData.PREFERENCES["Hates Sun"])
		
	if Input.is_action_just_pressed("unlock_all_tools"):
		print("unlock all tools")
		UI.get_node("JournalAndGuideUI").unlock_journal()
		Game.multitool.activate_tool(Game.multitool.TOOL.GROW)
		Game.multitool.activate_tool(Game.multitool.TOOL.PLANT)
		Game.multitool.activate_tool(Game.multitool.TOOL.HOPPER)
		
	if Input.is_action_just_pressed("play_spatial_audio"):
		Audio.fade_in("growbeam")
		
	if Input.is_action_just_pressed("flashlight"):
		Game.player.get_node("Head/Flashlight").visible = not Game.player.get_node("Head/Flashlight").visible
		
	if Input.is_action_just_pressed("lod_trigger"):
		cheat_lod = not cheat_lod
		Game.planet.trigger_lod(cheat_lod)
		
	if Input.is_action_just_pressed("sound_overload"):
		for i in range(20):
			Audio.play("plant_growth_stage" + str(i%3 + 1))

signal changed_state(state, prev_state)
func set_game_state(state):
	# complicated way since there may be special actions needed per state
	# or sometimes the new state shouldn't be set maybe if it doesn't make sense
	# stuff like mouse capturing could go here so that it's only done in one special position
	# (though note that on web browsers the first mouse capture has to be done in _input() !)
	var prev_state = game_state
	game_state = state
	
	emit_signal("changed_state", state, prev_state)


func is_ingame():
	return game_state == State.INGAME

var slerp_player_basis_a : Basis
var slerp_player_basis_b : Basis
func slerp_player_basis(f: float):
	player.global_transform.basis = slerp_player_basis_a.slerp(slerp_player_basis_b, f)

func execute_planet_hop(new_planet: Planet, pos: Vector3):
	#pos = new_planet.global_translation + new_planet.global_translation.direction_to(player.global_translation) * 10.0 - player.global_transform.basis.y * 2.0
	var dir_to_planet = player.global_translation.direction_to(new_planet.global_translation)
	pos = new_planet.global_translation + player.global_translation.direction_to(pos).cross(-dir_to_planet).cross(dir_to_planet).normalized() * 15.0
	set_game_state(State.WARPING)
	planet.fade_out()
	planet.set_player_is_on_planet(false)
	new_planet.set_player_is_on_planet(true)
	new_planet.fade_in()
	planet = new_planet
	#player.global_transform = Transform(new_basis, pos)
	var current_y_looking_angle : float = player.get_node("Head").rotation.x
	var target_y_looking_angle : float = -deg2rad(90.0) + player.global_translation.direction_to(pos).angle_to(pos.direction_to(planet.global_translation))
	slerp_player_basis_a = player.global_transform.basis
	slerp_player_basis_b = Utility.get_basis_y_aligned_with_z(new_planet.global_translation.direction_to(pos), -player.global_transform.basis.z) 
	$WarpTween.interpolate_method(self, "slerp_player_basis", 0.0, 1.0, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	$WarpTween.interpolate_property(player, "global_translation", player.global_translation, pos, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	$WarpTween.interpolate_property(player.get_node("Head"), "rotation:x", current_y_looking_angle, target_y_looking_angle, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	$WarpTween.start()
	yield(get_tree(), "idle_frame")
	sun.start_sound()
	Audio.play("hop_launch")
	yield($WarpTween, "tween_all_completed")
	Audio.play("hop_landing" + str(1 + randi() % 3))
	sun.end_sound()
	planet.configure_light(multitool)
	player.update_look_direction()
	Events.trigger("planet_hopped")
	set_game_state(State.INGAME)


func _on_SettingsOpenCooldown_timeout() -> void:
	pass # one shot
