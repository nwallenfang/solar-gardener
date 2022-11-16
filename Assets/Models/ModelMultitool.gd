extends Spatial

func set_hopper(active: bool):
	$HopperRings.set_active(active)
	$HopperPlayer.play("on" if active else "off")
