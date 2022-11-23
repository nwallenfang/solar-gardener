extends Spatial

func _ready():
	$Particles.emitting = true
	if is_instance_valid(Game.planet):
		$Particles.draw_pass_1.surface_get_material(0).set("albedo_color", Game.planet.dirt_pile_color)
	yield(get_tree().create_timer(4),"timeout")
	queue_free()
