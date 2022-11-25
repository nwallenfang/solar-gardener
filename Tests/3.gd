extends Spatial


func _ready() -> void:
	OS.set_window_size(Vector2(400, 400))
	get_viewport().size = Vector2(400, 400)
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	
	var capture = get_viewport().get_texture().get_data()
	capture.flip_y()
	# save to a file
	capture.save_png("screenshot.png")
	
	get_tree().quit(0)
