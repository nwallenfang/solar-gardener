extends Spatial

export var animation_length: float  = 6.0
export var animation_strength: float = 0.1

func _physics_process(delta):
	$Mesh.global_transform.basis = Utility.get_basis_y_aligned_with_z(Game.player.global_translation.direction_to(self.global_translation), Vector3.UP).orthonormalized().scaled(global_transform.basis.get_scale())
