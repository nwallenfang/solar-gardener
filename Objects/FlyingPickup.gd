extends Spatial

var identity: String

var is_flying := false
const MAX_VELOCITY = 20.0
var current_velocity := 0.0
const PICKUP_RANGE = .15

func _ready():
	$HoverPlayer.play("hover")

const FAKE_SEED = preload("res://Plants/FakeSeed.tscn")
func setup_as_seed(seed_name: String):
	identity = seed_name
	var fake_seed = FAKE_SEED.instance()
	$Object.add_child(fake_seed)
	fake_seed.setup(seed_name)

func on_pickup():
	if identity in PlantData.seed_counts.keys():
		PlantData.give_seeds(identity, 1)
	queue_free()

func start_flying():
	$VelocityTween.interpolate_property(self, "current_velocity", 0.0, MAX_VELOCITY, 2.0)
	$VelocityTween.start()
	is_flying = true

func _physics_process(delta):
	if is_flying:
		global_translation += current_velocity * delta * global_translation.direction_to(Game.player.pickup_point.global_translation)
		if global_translation.distance_to(Game.player.pickup_point.global_translation) < PICKUP_RANGE:
			on_pickup()
