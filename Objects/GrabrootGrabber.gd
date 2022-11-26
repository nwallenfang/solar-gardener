extends Spatial

var planet: Planet

func emerge(pos: Vector3):
	Audio.play("special_grabroot")
	visible = true
	global_transform.basis = Utility.get_basis_y_aligned(planet.global_translation.direction_to(pos))
	global_translation = planet.global_translation
	$Tween.interpolate_property(self, "global_translation", global_translation, pos, 6.0, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	if has_node("Amber"):
		var amber = get_node("Amber")
		amber.force_reload_seeds()

func _ready():
	visible = false
	planet = get_parent()

var analyse_name := "Grabroot Branch"

func get_analyse_text():
	return "Grabroots rarely\npull hidden\nobjects to\nthe surface"
