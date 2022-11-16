extends Spatial

var home_planet : Planet

func _ready():
	#yield(get_tree(),"idle_frame")
	if get_parent() is Planet:
		print("!")
		home_planet = get_parent() as Planet
		home_planet.add_to_lod_list(self)

func on_lod(lod_triggered: bool):
	var no_lod_meshes := [	$ModelShed/ShedSolarPanels,
							$ModelShed/ShedRoundWindow,
							$ModelShed/ShedRoof,
							$ModelShed/ShedRoofWoodenFoundation,
							$ModelShed/ShedBase,
							$ModelShed/ShedFoundation,
							$ModelShed/ShedFoundationPillar,
							$ModelShed/ShedWoodenPilar,
							]
	for c in $ModelShed.get_children():
		if not c in no_lod_meshes:
			c.visible = not lod_triggered
	$OmniLight.visible = not lod_triggered

