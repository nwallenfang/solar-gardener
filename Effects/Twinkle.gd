extends Spatial

export var cold := false
export var both := false

func _ready():
	if cold:
		$Particles.visible = false
		$ParticlesCold.visible = true
	if both:
		$Particles.visible = true
		$ParticlesCold.visible = true
