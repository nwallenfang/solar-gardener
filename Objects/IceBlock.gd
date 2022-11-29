extends Spatial

var analyse_name := "Ice Block"

var melting := false
func melt():
	if melting:
		return
	melting = true
	$MeltingTween.interpolate_property($Ice, "scale", $Ice.scale, $Ice.scale * .01, 3.0, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$MeltingTween.start()
	yield($MeltingTween,"tween_all_completed")
	$Ice.queue_free()

var almost_melting := false
func almost_melt():
	if almost_melting:
		return
	almost_melting = true
	$AnimationPlayer.play("almost_melt")

func get_analyse_text():
	if almost_melting:
		return "It started melting\nbut it needs a\nstronger heat source."
	else:
		return "Should melt\nat great heat"
