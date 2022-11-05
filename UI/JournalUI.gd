extends Control

# TODO later this JournalUI will be used in a ViewportTexture

func _ready() -> void:
	PlantData.connect("new_progress", self, "new_progress")


func new_progress():
	pass


func init():
	pass


func show():
	# TODO play show Journal animation (tool screen moving towards player cam basically)
	self.visible = true
	
	
func hide():
	self.visible = false
