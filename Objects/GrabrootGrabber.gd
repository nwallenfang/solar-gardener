extends Spatial

var planet: Planet

func emerge(pos: Vector3):
	visible = true
	global_transform.basis = Utility.get_basis_y_aligned(planet.global_translation.direction_to(pos))
	global_translation = planet.global_translation
	$Tween.interpolate_property(self, "global_translation", global_translation, pos, 6.0, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()

func _ready():
	visible = false
	planet = get_parent()
