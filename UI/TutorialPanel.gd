extends Control

const tutorial_panel_default_anchors = [0.691, 0.025, 0.967, 0.296]

func _ready():
	$Panel.visible = false

func show_tutorial_message(title: String, text: String):
	$Panel.visible = true
	$"%Title".text = title
	$"%Text".text = text
	
func done_with_tutorials():
	$Panel.visible = false


func hide_message():
	$Panel.visible = false
