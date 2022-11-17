extends Spatial

var currently_active := true

var dummy_alpha := 0.0

func set_active(active: bool):
	if active != currently_active:
		currently_active = active
		$Tween.stop_all()
		$Tween.remove_all()
		if active:
			self.visible = true
			$Tween.interpolate_property($MeshInstance.material_override, "shader_param/alpha", 0.0, 1.0, 1.0)
			$Tween.interpolate_property($MeshInstance2.material_override, "shader_param/alpha", 0.0, 1.0, 1.0)
			$Tween.interpolate_property($MeshInstance3.material_override, "shader_param/alpha", 0.0, 1.0, 1.0)
			$Tween.interpolate_property(self, "dummy_alpha", 0.0, 1.0, 1.0)
			$Tween.start()
		else:
			$Tween.interpolate_property($MeshInstance.material_override, "shader_param/alpha", dummy_alpha, 0.0, .3)
			$Tween.interpolate_property($MeshInstance2.material_override, "shader_param/alpha", dummy_alpha, 0.0, .3)
			$Tween.interpolate_property($MeshInstance3.material_override, "shader_param/alpha", dummy_alpha, 0.0, .3)
			$Tween.interpolate_property(self, "dummy_alpha", dummy_alpha, 0.0, .3)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			self.visible = false

func _ready():
	set_active(false)
