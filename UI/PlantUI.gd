extends Control
class_name PlantUI

const STAR_FULL = preload("res://Assets/Sprites/star-full.png")
const STAR_EMPTY = preload("res://Assets/Sprites/star-empty.png")

var plant_name
var number_of_stars = 0
var hovered = false

var plant_profile: PlantProfile
var discovered_plant_preferences = []

signal clicked(plant_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

const PREFERENCE_UI = preload("res://UI/PlantPreferenceUI.tscn")
func add_preference(preference: PlantPreference):
	var preference_ui = PREFERENCE_UI.instance()
	$"%Preferences".add_child(preference_ui)
	preference_ui.set_preference_data(preference)
	$"%Preferences".columns = $"%Preferences".get_child_count()

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
