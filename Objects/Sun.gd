extends Spatial


# seems nonsensical but gets used for tweening :)
func linear_to_db(linear: float):
	$Audio3D.unit_db = linear2db(linear)


func start_sound():
	$Audio3D.unit_db = -80
	$Audio3D.play(randf() * $Audio3D.stream.get_length())
	$Tween.reset_all()
	$Tween.interpolate_method(self, "linear_to_db", 0.0, 1.0, 0.3)
	$Tween.start()
	
func end_sound():
	$Tween.reset_all()
	$Tween.interpolate_method(self, "linear_to_db", 1.0, 0.0, 1.0)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$Audio3D.stop()
