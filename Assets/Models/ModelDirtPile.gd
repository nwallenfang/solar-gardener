extends Spatial

func on_lod(lod_triggered: bool):
	self.visible = not lod_triggered
