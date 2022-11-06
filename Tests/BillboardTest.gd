extends Spatial

func _physics_process(delta):
	global_transform.basis = Utility.get_basis_y_alligned_with_z(Game.player.global_translation.direction_to(self.global_translation), Vector3.UP).scaled(Vector3.ONE * 20.0)
