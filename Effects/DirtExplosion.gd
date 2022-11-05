extends Spatial

func _ready():
	$Particles.emitting = true
	yield(get_tree().create_timer(3),"timeout")
	queue_free()
