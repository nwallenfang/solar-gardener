extends Spatial

#export var animation_length: float  = 6.0
#export var animation_strength: float = 0.1
#export var movement_noise: NoiseTexture
#export var movement_speed: float

const aura2_offset: Vector2 = Vector2(1.0, 0.6)

var scale_saved: Vector3
export var scale_factor: float

func _ready() -> void:
	scale_saved = global_transform.basis.get_scale()
	$AnimationPlayer.play("aura_scale")

func _physics_process(delta):
	var target: Spatial = Game.player

	if Game.game_state == Game.State.INTRO_FLIGHT:
		target = Game.world.get_node("%FlyCamera")
		
	if Game.game_state == Game.State.CREDITS:
		# should work always but just taking it for credits not to break anything
		target = get_viewport().get_camera()

	if target != null:
		var up_vector: Vector3 = target.global_translation.direction_to(self.global_translation)
		$Mesh.global_transform.basis = Utility.get_basis_y_aligned_with_z(up_vector, Vector3.UP)
		$Mesh.global_transform.basis = $Mesh.global_transform.basis.orthonormalized().scaled(scale_saved * scale_factor)
	
