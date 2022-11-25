extends TextureRect
const unknown_pref: PlantPreference = preload("res://Plants/Preferences/Unknown.tres")

#onready var unknown = preload("res://Plants/Preferences/Unknown.tres").instance()
var is_unknown = true
var preference: PlantPreference
var plant_name: String

export var disabled = true setget set_disabled

func _ready() -> void:
	if not disabled:
		hint_tooltip = unknown_pref.description
		texture = unknown_pref.icon

func make_known():
	if preference == null:
		return
	if is_unknown and Game.journal.get_got_scanned(plant_name):
		Game.UI.show_info_line("%s preference discovered!" % plant_name, 1)
	is_unknown = false
	hint_tooltip = preference.description
	texture = preference.icon

func set_disabled(val):
	disabled = val
	if disabled:
		hint_tooltip = ""
		texture = null
	else:
		if is_unknown:
			hint_tooltip = unknown_pref.description
			texture = unknown_pref.icon

func set_preference_data(new_preference: PlantPreference, new_plant_name: String):
	self.preference = new_preference
	self.plant_name = new_plant_name

