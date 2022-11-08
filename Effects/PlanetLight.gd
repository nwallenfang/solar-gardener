extends Spatial

var number := 0
var mask_value := 0

func setup(_number: int):
	number = _number
	mask_value = int(pow(2, number))
	$DirectionalLight.light_cull_mask = mask_value
	self.global_transform.basis = Utility.get_basis_y_aligned(Game.sun.global_translation.direction_to(self.global_translation))
