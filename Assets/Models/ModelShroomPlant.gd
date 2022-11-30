extends Spatial

var analyse_name := "Foreign Mushroom"

func get_analyse_text():
	return "Somehow it\nmanaged to\ngrow on this\nhard soil."

func on_analyse():
	Game.shed.trigger_trophy("AlienShroom")
