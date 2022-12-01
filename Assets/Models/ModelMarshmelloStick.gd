extends Spatial

var analyse_name := "Marshmello Stick"

func on_analyse():
	Game.shed.trigger_trophy("Marshmello")
	$Area/CollisionShape.disabled = true
