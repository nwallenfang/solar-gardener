extends Spatial

export(String, MULTILINE) var note_text: String

func on_analyse():
	Game.UI.set_note_text(note_text)
	Game.game_state = Game.State.READING_NOTE
