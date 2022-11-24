extends Control

const tutorial_panel_default_anchors = [0.691, 0.025, 0.967, 0.296]

func _ready():
	$Panel.visible = false

func new_msg_sound():
	Audio.play("ui_activate2")

func show_tutorial_message(title: String, text: String):
	$Panel.rect_pivot_offset = 0.5 * $Panel.rect_size
	$Panel.rect_scale = Vector2(0.0, 0.0)
	$Panel.visible = true
	$"%Title".text = title
	$"%Text".text = text
	
	$AnimationPlayer.play("pop_in")
	
func done_with_tutorials():
	$Panel.visible = false


func hide_message():
	$AnimationPlayer.play("pop_out")
