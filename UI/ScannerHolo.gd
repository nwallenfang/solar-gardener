extends Control
class_name ScannerHolo

export var special_color: Color = Color("5b56ac")
export var default_color: Color = Color("51b19b")

var current_screen: Control

var pref_uis := []

export var real := false

func _ready() -> void:
	yield(get_tree().create_timer(11),"timeout")
	if real:
		Game.scanner_holo = self
		print("Set Holoscreen")

	pref_uis.append($AspectRatioContainer/VBoxContainer/SoilInfo/PlantPreferenceUI1)
	pref_uis.append($AspectRatioContainer/VBoxContainer/SoilInfo/PlantPreferenceUI2)
	pref_uis.append($AspectRatioContainer/VBoxContainer/SoilInfo/PlantPreferenceUI3)
	pref_uis.append($AspectRatioContainer/VBoxContainer/SoilInfo/PlantPreferenceUI4)
	pref_uis.append($AspectRatioContainer/VBoxContainer/SoilInfo/PlantPreferenceUI5)

var quad: MeshInstance

func show_preferences(preferences: Array):
	quad.visible = true

	for p in pref_uis:
		p.visible = false
	var i := 0
	for preference in preferences:
		var pref_ui = pref_uis[i]
		pref_ui.visible = true
		pref_ui.texture = PlantData.PREFERENCES[preference].icon
		i += 1
	
	yield(get_tree().create_timer(3.5),"timeout")
	quad.visible = false

