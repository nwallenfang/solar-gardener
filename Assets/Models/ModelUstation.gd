extends Spatial

func set_open(open: bool):
	$AnimationPlayer.play("open" if open else "close")

func ring_whirl():
	for i in range(10):
		var torus : Spatial = get_node("Pivot/Torus00" + str(i))
		torus.rotation_degrees = Vector3(90, -90, -90)
		get_tree().create_tween().tween_property(torus, "rotation_degrees:x", 90.0+360.0, 1.0)
		yield(get_tree().create_timer(.06),"timeout")
