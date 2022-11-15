extends Control

func _ready():
	$Panel.visible = false

func show_tutorial_message(title: String, text: String):
	$Panel.visible = true
	$"%Title".text = title
	$"%Text".text = text
	
func done_with_tutorials():
	$Panel.visible = false

