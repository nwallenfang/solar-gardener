extends Spatial

export(Color) var grow_color : Color
export(Color) var grow_color2 : Color
export(Color) var death_color : Color
export(Color) var death_color2 : Color

func set_death_color(active: bool):
	if active:
		$MeshInstance.material_override.set("shader_param/albedo", death_color)
		$MeshInstance.material_override.set("shader_param/albedo2", death_color2)
	else:
		$MeshInstance.material_override.set("shader_param/albedo", grow_color)
		$MeshInstance.material_override.set("shader_param/albedo2", grow_color2)
