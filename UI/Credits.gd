extends Control

signal change_to_camera_2
signal change_to_camera_3
signal credits_done


func change_to_2():
	emit_signal("change_to_camera_2")
	
func change_to_3():
	emit_signal("change_to_camera_3")

func _on_SkipCreditsButton_pressed() -> void:
	emit_signal("credits_done")
	
