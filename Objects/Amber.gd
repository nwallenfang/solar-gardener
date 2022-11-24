extends Spatial

export var seed_name : String
export var seed_count : int

const FLYING_PICKUP = preload("res://Objects/FlyingPickup.tscn")

var analyse_name = "Amber Relict"

var pickup: Spatial

func on_analyse():
#	var pickup = FLYING_PICKUP.instance()
#	Game.planet.add_child_with_light(pickup)
#	pickup.global_transform.basis = Utility.get_basis_y_aligned(Game.planet.global_translation.direction_to(self.global_translation))
#	pickup.global_translation = self.global_translation
#	pickup.setup_as_seed(seed_name)
#	# TODO Seed count?
	$Tween.interpolate_property(self, "scale", self.scale, Vector3.ONE * .01, 3.0)
	$Tween.start()
	yield(get_tree().create_timer(1.5), "timeout")
	pickup.start_flying()
	yield($Tween, "tween_all_completed")
	Events.trigger("tutorial_amber_collected")
	
	queue_free()



func _on_VisibilityNotifier_camera_entered(camera):
	if camera == Game.camera and pickup == null and seed_name in PlantData.profiles:
		pickup = FLYING_PICKUP.instance()
		Game.planet.add_child_with_light(pickup)
		pickup.global_transform.basis = Utility.get_basis_y_aligned(Game.planet.global_translation.direction_to(self.global_translation))
		pickup.global_translation = $SeedPos.global_translation
		pickup.setup_as_seed(seed_name, 1.3, false, false, .2)
