extends Camera

func _ready():
	Game.player_raycast = $PlayerRayCast
	Game.multitool = $ObjectUI/Multitool
