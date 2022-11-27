extends Spatial

const GREEN_OVERLAY = preload("res://Assets/Materials/GreenAlphaOverlay.tres")
func activate():
	var meshes : Array = Utility.get_all_mesh_instance_children($ModelPlant_01_ranke_state00)
	for mi in meshes:
		mi = mi as MeshInstance
		mi.material_overlay = GREEN_OVERLAY.duplicate()
	
	$ModelMultitool.set_grow_beam_on_target(Game.sun)
	$ModelMultitool.set_grow(true)
	$ModelMultitool/AnalysePlayer.play("on")
	$ModelMultitool/HopperPlayer.play("on")
	$ModelMultitool/PlantPlayer.play("on")
	$ModelMultitool/SlingshotPlayer.play("on")
	$ModelMultitool/GrowBeamPlayer.play("on")
	for c in get_children():
		if c is Particles:
			c.one_shot = true
			c.emitting = true
		for cc in c.get_children():
			if cc is Particles:
				cc.one_shot = true
				cc.emitting = true

	$ModelMultitool/AnalysePlayer.play("off")
	$ModelMultitool/HopperPlayer.play("off")
	$ModelMultitool/PlantPlayer.play("off")
	$ModelMultitool/SlingshotPlayer.play("off")
	$ModelMultitool/GrowBeamPlayer.play("off")
