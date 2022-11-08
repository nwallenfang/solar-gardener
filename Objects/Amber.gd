extends Spatial

export var seed_name : String
export var seed_count : int

const FLYING_PICKUP = preload("res://Objects/FlyingPickup.tscn")

var analyse_name = "Piece of Amber"

func on_analyse():
	var pickup = FLYING_PICKUP.instance()
	Game.planet.add_child_with_light(pickup)
	pickup.global_transform.basis = Utility.get_basis_y_aligned(Game.planet.global_translation.direction_to(self.global_translation))
	pickup.global_translation = self.global_translation
	pickup.setup_as_seed(seed_name)
	# TODO Seed count?
	$Tween.interpolate_property($Model, "scale", Vector3.ONE, Vector3.ONE * .01, 3.0)
	$Tween.start()
	yield(get_tree().create_timer(1.5), "timeout")
	pickup.start_flying()
	yield($Tween, "tween_all_completed")
	queue_free()

