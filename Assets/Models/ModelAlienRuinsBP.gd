extends Spatial

var analyse_name := "Foreign Object"

func get_analyse_text():
	return "Appears to be\n a light source\nfrom another\ncivilisation."

func on_analyse():
	Game.shed.trigger_trophy("Alien")
