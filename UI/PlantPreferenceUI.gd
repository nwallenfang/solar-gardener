extends TextureRect
const unknown_pref: PlantPreference = preload("res://Plants/Preferences/Unknown.tres")

#onready var unknown = preload("res://Plants/Preferences/Unknown.tres").instance()
var is_unknown = true
var preference: PlantPreference

export var disabled = true setget set_disabled

func _ready() -> void:
	if not disabled:
		hint_tooltip = unknown_pref.description
		texture = unknown_pref.icon

func make_known():
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

func set_preference_data(new_preference: PlantPreference):
	self.preference = new_preference

