extends Control
class_name PlantUI

const STAR_FULL = preload("res://Assets/Sprites/star-full.png")
const STAR_EMPTY = preload("res://Assets/Sprites/star-empty.png")

var number_of_preferences = 0
var plant_name
var number_of_stars = 0
var hovered = false

var discovered = false
var scanned = false

var plant_profile: PlantProfile


signal clicked(plant_name)


func _ready() -> void:
	$Panel/UndiscoveredOverlay.visible = true
	$SeedCountBG.visible = false

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

# delete?
#func get_data_for_plant(new_plant_name):
#	self.plant_name = new_plant_name
#	# GET ALL THE DATA FROM PlantData singleton
#	self.number_of_stars = 2
	
	
func set_seed_count(seed_count: int):
	if not discovered:
		$Panel/UndiscoveredOverlay.visible = false
		$SeedCountBG.visible = true
		discovered = true
	$"%SeedCount".text = str(seed_count)
	$SeedCountBG.hint_tooltip = str(seed_count) + " Seed(s) available"


func set_number_of_stars(number):
	number_of_stars = number
	
	for i in range(number_of_stars):
		var star_texture_rect: TextureRect = get_node("Panel/Stars/Star" + str(i+1))
		star_texture_rect.texture = STAR_FULL
		star_texture_rect.hint_tooltip = "Grown to Stage " + str(i+2)

func _on_Panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.pressed and event.button_index == BUTTON_LEFT and discovered:
			emit_signal("clicked", plant_name)

signal plant_got_hovered(plant_ui)
func _on_Panel_mouse_entered() -> void:
	if not hovered and discovered:
		hovered = true
		emit_signal("plant_got_hovered", self)

func _on_Panel_mouse_exited() -> void:
	if hovered:
		hovered = false
		
func got_scanned():
	scanned = true
	$Panel.hint_tooltip = plant_profile.name
	$Panel/Stars.visible = true
	$Panel/Preferences.visible = true
