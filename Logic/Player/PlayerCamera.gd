extends Camera
class_name PlayerCamera

func _ready():
	Game.camera = self
	Game.player_raycast = $PlayerRayCast
	Game.multitool = $ObjectUI/Multitool


func set_screen_texture(tex: ViewportTexture):
	$UIScreen/ScreenMesh.get_active_material(0).albedo_texture = tex



export var noise : OpenSimplexNoise
var time := 0.0
var trauma := 0.0
var trauma_reduction := .75
func screen_shake():
	trauma = 2.0

func _process(delta):
	if trauma > 0.0:
		trauma = max(trauma - delta * trauma_reduction, 0.0)
		time += delta
		
		rotation_degrees.x = 15.0 * get_shake_intensity() * get_noise_from_seed(1)
		rotation_degrees.y = 15.0 * get_shake_intensity() * get_noise_from_seed(2)
		rotation_degrees.z = 8.0 * get_shake_intensity() * get_noise_from_seed(3)


func get_shake_intensity() -> float:
	return min(trauma, 1.0) * min(trauma, 1.0)

func get_noise_from_seed(_seed: int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * 50.0)
