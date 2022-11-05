extends Control

# TODO later this JournalUI will be used in a ViewportTexture

func _ready() -> void:
	pass 
	

func show():
	# TODO play show Journal animation (tool screen moving towards player cam basically)
	self.visible = true
	
	
func hide():
	self.visible = false
