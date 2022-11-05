extends TextureRect

func set_preference_data(preference: PlantPreference):
	hint_tooltip = preference.description
	texture = preference.icon
