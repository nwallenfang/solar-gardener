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
