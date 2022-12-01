extends Spatial

var analyse_name := "Marshmello Stick"

func on_analyse():
	Game.shed.trigger_trophy("Marshmello")

func get_analyse_text() -> String:
	return "Seems to be\nfrom the\nOuter Wilds"
