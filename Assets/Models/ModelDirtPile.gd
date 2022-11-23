extends Spatial

func on_lod(lod_triggered: bool):
	self.visible = not lod_triggered
	if not lod_triggered:
		$Pile.material_override.set("albedo_color", Game.planet.dirt_pile_color)
