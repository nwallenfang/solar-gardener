extends Spatial

var analyse_name := "Ice Block"

var melting := false
func melt():
	if melting:
		return
	melting = true
	$AnimationPlayer.stop()
	$MeltingTween.interpolate_property($Ice, "scale", $Ice.scale, .001, 3.0, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$MeltingTween.start()
	yield($MeltingTween,"tween_all_completed")
	$Ice.queue_free()

var almost_melting := false
func almost_melt():
	if almost_melting:
		return
	almost_melting = true
	$AnimationPlayer.play("almost_melt")
	$Ice/Twinkles.visible = false

func get_analyse_text():
	if almost_melting:
		return "It started\nmelting but\nit needs a\nstronger\nheat source."
	else:
		return "Should melt\nat great heat"
