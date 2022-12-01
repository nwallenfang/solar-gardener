extends Spatial

const GREEN_OVERLAY = preload("res://Assets/Materials/GreenAlphaOverlay.tres")
func activate():
	var meshes : Array = Utility.get_all_mesh_instance_children($ModelPlant_01_ranke_state00)
	for mi in meshes:
		mi = mi as MeshInstance
		mi.material_overlay = GREEN_OVERLAY.duplicate()
	
	for c in get_children():
		if c is Particles:
			c.one_shot = true
			c.emitting = true
		for cc in c.get_children():
			if cc is Particles:
				cc.one_shot = true
				cc.emitting = true
	
	$ModelMultitool.set_grow_beam_on_target(Game.sun)
	$ModelMultitool.set_grow(true)
	$ModelMultitool/AnalysePlayer.playback_speed = 20.0
	$ModelMultitool/PlantPlayer.playback_speed = 20.0
	$ModelMultitool.set_plant(true)
	$ModelMultitool/AnalysePlayer.play("on")
	$ModelMultitool/HopperPlayer.play("on")
	$ModelMultitool/PlantPlayer.play("on")
	$ModelMultitool/SlingshotPlayer.play("reload")
	$ModelMultitool/GrowBeamPlayer.play("on")
	#yield($ModelMultitool/PlantPlayer,"animation_finished")
	yield(get_tree().create_timer(.05),"timeout")
	
	yield(get_tree().create_timer(.1),"timeout")
	$ModelMultitool/AnalysePlayer.play("off")
	$ModelMultitool/HopperPlayer.play("off")
	$ModelMultitool/PlantPlayer.play("off")
	#$ModelMultitool/SlingshotPlayer.play("off")
	$ModelMultitool/GrowBeamPlayer.play("off")
	
	yield(get_tree().create_timer(.2),"timeout")
	queue_free()
