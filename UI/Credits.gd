extends Control
class_name Credits

signal change_to_camera_2
signal change_to_camera_3
signal credits_done

func _ready() -> void:
	Game.credits = self

func change_to_2():
	emit_signal("change_to_camera_2")
	
func change_to_3():
	emit_signal("change_to_camera_3")

func emit_credits_done():
	emit_signal("credits_done")

func _on_SkipCreditsButton_pressed() -> void:
	$Credits2D.stop()
	Game.credits_skipped()

func start():
	$Credits2D.play("credits")
