extends Control
class_name ScannerHolo

export var special_color: Color = Color("5b56ac")
export var default_color: Color = Color("51b19b")

var current_screen: Control

func _ready() -> void:
	Game.scanner_holo = self
	var pref_ui = get_node("%PlantPreferenceUI" + str(2))
	pref_ui.texture = load("res://Assets/Sprites/godot_icon.png")

func show_preferences(preferences: Array):
#	for pref_ui in $AspectRatioContainer/VBoxContainer/SoilInfo.get_children():
#		pref_ui.visible = false
	var i = 0
	var number = len(preferences)
	for preference in preferences:
		i += 1
		var pref_ui = get_node("AspectRatioContainer/VBoxContainer/SoilInfo/PlantPreferenceUI" + str(i))
		pref_ui.visible = true
#		pref_ui.texture = PlantData.PREFERENCES[preference].icon
#		print("icon: " + str(PlantData.PREFERENCES[preference].icon)
		print("show " + str(pref_ui) + " " + str(preference))
	

