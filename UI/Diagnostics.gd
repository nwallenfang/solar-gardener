extends VBoxContainer

func _ready() -> void:
	if OS.is_debug_build():
		set_process(true)
	
		yield(get_tree().create_timer(2.5), "timeout")
		var start_history = Array()
		start_history.resize(history_size)
		start_history.fill(Engine.get_frames_per_second())
		fps_history = start_history
		average_fps = Engine.get_frames_per_second()
		$FPSUpdateTimer.start()
	else:
		set_process(false)  # could be enabled explicitly if wanted
	

export var time_interval_for_avg = 10.0
var fps_history = []
onready var history_size = time_interval_for_avg / $FPSUpdateTimer.wait_time
var average_fps := 0.0
var old_fps
var visuals_every = 5
var counter = 0
func _on_FPSUpdateTimer_timeout() -> void:
	var fps = Engine.get_frames_per_second()
	$FPS2.text = "FPS: %.0f" % fps
#	if fps_history.empty():
#		var start_history = 
#		fps_history.append_array()
	fps_history.append(fps)
	
		
	if len(fps_history) > history_size:
		# supposed to have bad performance for large arrays but should be fine here
		old_fps = fps_history.pop_front()
		average_fps += (fps-old_fps)/history_size
	else:
		printerr("SHOULD NOT HAPPEN")
#		average_fps += (fps * (history_size - len(fps_history)))/history_size


		
	if counter == 0:
		$FPS.text = "avg FPS: %.0f" % average_fps
	
	counter += 1
	counter %= visuals_every
