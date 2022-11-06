extends Control
class_name PlantUI

const STAR_FULL = preload("res://Assets/Sprites/star-full.png")
const STAR_EMPTY = preload("res://Assets/Sprites/star-empty.png")

var number_of_preferences = 0
var plant_name
var number_of_stars = 0
var hovered = false

var plant_profile: PlantProfile
var discovered_plant_preferences = []

signal clicked(plant_name)


const max_per_row = 3
func add_preference(preference: PlantPreference):
	var next_preference = get_node("Panel/Preferences/PlantPreferenceUI" + str(number_of_preferences+1))
	next_preference.set_preference_data(preference)
	next_preference.disabled = false
	number_of_preferences += 1

func make_preference_known(preference: PlantPreference):
	# find this preference
	for pref_ui in $"%Preferences".get_children():
		if pref_ui.preference == preference:
			pref_ui.make_known()
			return
	printerr("plant " + plant_name + " doesn't have the preference " + preference + " ERR")

func get_data_for_plant(new_plant_name):
	self.plant_name = new_plant_name
	# GET ALL THE DATA FROM PlantData singleton
	self.number_of_stars = 2
	
	
func set_seed_count(seed_count: int):
	$"%SeedCount".text = str(seed_count)


func set_number_of_stars(number):
	number_of_stars = number
	
	# TODO update UI
	for i in range(number_of_stars):
		var star_texture_rect: TextureRect = get_node("Panel/Stars/Star" + str(i+1))
		star_texture_rect.texture = STAR_FULL

func _on_Panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.pressed and event.button_index == BUTTON_LEFT:
			get_tree().set_input_as_handled()
			emit_signal("clicked", plant_name)

func _on_Panel_mouse_entered() -> void:
	if not hovered:
		hovered = true
		owner.call("plant_hovered", self)

func _on_Panel_mouse_exited() -> void:
	if hovered:
		hovered = false
