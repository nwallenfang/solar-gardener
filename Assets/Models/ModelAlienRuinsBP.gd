extends Spatial

var analyse_name := "Foreign Object"

func get_analyse_text():
	return "It appears to\nbe a light source\nmade by an other\ncivilisation."

func on_analyse():
	Game.shed.trigger_trophy("Alien")
