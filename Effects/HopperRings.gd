extends Spatial

var currently_active := true

func set_active(active: bool):
	if active != currently_active:
		currently_active = active
		$Tween.stop_all()
		$Tween.remove_all()
		if active:
			self.visible = true
			$Tween.interpolate_property($MeshInstance.material_override, "shader_param/albedo:a", 0.0, 1.0, .4)
			$Tween.interpolate_property($MeshInstance2.material_override, "shader_param/albedo:a", 0.0, 1.0, .4)
			$Tween.start()
		else:
			$Tween.interpolate_property($MeshInstance.material_override, "shader_param/albedo:a", 1.0, 0.0, .4)
			$Tween.interpolate_property($MeshInstance2.material_override, "shader_param/albedo:a", 1.0, 0.0, .4)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			self.visible = false

func _ready():
	set_active(false)
