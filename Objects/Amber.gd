extends Spatial

export var seed_name : String
export var seed_count : int

const FLYING_PICKUP = preload("res://Objects/FlyingPickup.tscn")

var analyse_name = "Amber Relict"

var pickups: Array

func on_analyse():
	$Tween.interpolate_property(self, "scale", self.scale, Vector3.ONE * .01, 3.0)
	$Tween.start()
	yield(get_tree().create_timer(1.1), "timeout")
	Audio.play("amber_obtain")
	for pickup in pickups:
		pickup.start_flying()
	yield($Tween, "tween_all_completed")
	Events.trigger("tutorial_amber_collected")
	Game.number_of_ambers += 1
	
	queue_free()

func _on_VisibilityNotifier_camera_entered(camera):
	if camera == Game.camera and pickups.empty() and seed_name in PlantData.profiles and Game.game_state == Game.State.INGAME:
		load_seeds()

func force_reload_seeds():
	for pickup in pickups:
		pickup.queue_free()
	pickups.clear()
	load_seeds()

func load_seeds():
	for child in $SeedPositions.get_children():
		var pickup = FLYING_PICKUP.instance()
		pickup.is_amber = true
		Game.planet.add_child_with_light(pickup)
		pickup.global_transform.basis = Utility.get_basis_y_aligned(Game.planet.global_translation.direction_to(self.global_translation))
		pickup.global_translation = child.global_translation
		pickup.setup_as_seed(seed_name, 1.3, false, false, .2)
		pickups.append(pickup)

#func _physics_process(delta):
#	if Input.is_action_just_pressed("jump"):
#		force_reload_seeds()
