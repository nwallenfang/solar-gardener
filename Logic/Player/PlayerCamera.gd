extends Camera
class_name PlayerCamera

func _ready():
	Game.camera = self
	Game.player_raycast = $PlayerRayCast
	Game.multitool = $ObjectUI/Multitool


func set_screen_texture(tex: ViewportTexture):
	$UIScreen/ScreenMesh.get_active_material(0).albedo_texture = tex
