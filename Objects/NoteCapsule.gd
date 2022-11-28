extends Spatial

export var last_note: bool = false

var first_time_opening = false
var index = -1

var analyse_name := "Old Note"

func on_analyse():
	Audio.fade_out("scanner", 0.55)
	if not first_time_opening:
		first_time_opening = true
		if last_note:
			index = Dialog.get_last_index()
		else:
			index = Dialog.get_next_index()
	Game.UI.set_note_text(Dialog.get_gardener_note(index))
	Game.get_node("SettingsOpenCooldown").start(0.4)
	Game.game_state = Game.State.READING_NOTE
	
	yield(get_tree().create_timer(0.8), "timeout")
	Dialog.play_gardener_voice_over(index)
