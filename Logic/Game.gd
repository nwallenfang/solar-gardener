extends Node

const MODELS_FOLDER = "res://Assets/Models/"

enum State {
	INGAME,
	SETTINGS,
	MAIN_MENU  # if it's needed 
}

var game_state = State.INGAME setget set_game_state
# is set from MainScene, if this is false, a subscene is running individually for testing,
# if this is true game is running normally
var main_scene_running = false
var main_scene = null
# is set when main_scene_running
var UI: UI = null
var player: Player = null
var invert_y_axis = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_settings"):  # show/hide settings UI
		if main_scene_running:
			if game_state == State.INGAME:
				self.game_state = State.SETTINGS
			elif game_state == State.SETTINGS:
				# this is only the correct if you can only enter settings from ingame!!
				self.game_state = State.INGAME


func set_game_state(state):
	# complicated way since there may be special actions needed per state
	# or sometimes the new state shouldn't be set maybe if it doesn't make sense
	# stuff like mouse capturing could go here so that it's only done in one special position
	# (though note that on web browsers the first mouse capture has to be done in _input() !)
	var prev_state = game_state
	match state:
		State.INGAME:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			game_state = State.INGAME
		State.MAIN_MENU:
			game_state = State.MAIN_MENU
		State.SETTINGS:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			UI.show_settings()
			game_state = State.SETTINGS
			
	if prev_state == State.SETTINGS and game_state != State.SETTINGS:
		pass
#		UI.hide_settings()


func is_ingame():
	return game_state == State.INGAME
