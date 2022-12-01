extends Spatial

var analyse_name := "Marshmello Stick"

func on_analyse():
	Audio.play("ow_whistle")
	Game.shed.trigger_trophy("Marshmello")

func get_analyse_text() -> String:
	return "Seems like some\ntraveler had\na comfy break"
