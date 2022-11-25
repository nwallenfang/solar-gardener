extends Spatial
class_name PlanetLight

var number := 0
var mask_value := 0
var planet: Spatial

const DISTANCE_TO_PLANET = 160.0

func setup(_number: int, _planet: Spatial):
	number = _number
	planet = _planet
	mask_value = int(pow(2, number))
	
#	$DirectionalLight.directional_shadow_depth_range = DirectionalLight.SHADOW_DEPTH_RANGE_STABLE
#	$DirectionalLight.directional_shadow_max_distance = 40.0  # depends on planet size
	$DirectionalLight.light_cull_mask = mask_value
	$SpotLight.light_cull_mask = mask_value
	self.global_transform.basis = Utility.get_basis_y_aligned(Game.sun.global_translation.direction_to(planet.global_translation))
	self.global_translation = planet.global_translation + planet.global_translation.direction_to(Game.sun.global_translation) * DISTANCE_TO_PLANET
	$DirectionalLight.global_translation = planet.global_translation

func set_player_is_on_planet(on_planet: bool):
	$DirectionalLight.visible = on_planet
	$SpotLight.visible = not on_planet
