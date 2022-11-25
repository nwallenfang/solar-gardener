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
var stage2_scanned = false
var stage3_scanned = false

var plant_profile: PlantProfile setget set_profile

export var anchor_left_scanned := 0.41
signal clicked(plant_name)


func _ready() -> void:
	$Panel/UndiscoveredOverlay.visible = true
	$SeedCountBG.visible = false

func set_profile(profile: PlantProfile):
	plant_profile = profile
	$Panel/PlantIcon.texture = profile.icon
	$Panel/PlantIcon.anchor_left = 0.0
	$Panel/PlantIcon.rect_pivot_offset = 0.5 * $Panel/PlantIcon.rect_size
	$Panel/PlantIcon.rect_scale = Vector2(0.7, 0.7)

const max_per_row = 3
func add_preference(preference: PlantPreference):
	var next_preference = get_node("Panel/Preferences/PlantPreferenceUI" + str(number_of_preferences+1))
	next_preference.set_preference_data(preference, plant_profile.name)
	next_preference.disabled = false
	number_of_preferences += 1

func make_preference_known(preference_name: String):
	# find this preference
	for pref_ui in $"%Preferences".get_children():
		if pref_ui.preference.name == preference_name:
			pref_ui.make_known()
			return
	printerr("plant " + plant_name + " doesn't have the preference " + preference_name + " ERR")


func make_all_preferences_known():
	for pref_ui in $"%Preferences".get_children():
		pref_ui.make_known()
# delete?
#func get_data_for_plant(new_plant_name):
#	self.plant_name = new_plant_name
#	# GET ALL THE DATA FROM PlantData singleton
#	self.number_of_stars = 2
func set_to_discovered():
		$Panel/UndiscoveredOverlay.visible = false
		$SeedCountBG.visible = true
		discovered = true	
	
func set_seed_count(seed_count: int):
	if not discovered:
		$Panel/UndiscoveredOverlay.visible = false
		$SeedCountBG.visible = true
		discovered = true
	$"%SeedCount".text = str(seed_count)
	if seed_count != 1:
		$SeedCountBG.hint_tooltip = str(seed_count) + " Seeds available"
	else:
		$SeedCountBG.hint_tooltip = "1 Seed available"


func set_number_of_stars(number):
	number_of_stars = number
	
	for i in range(number_of_stars):
		var star_texture_rect: TextureRect = get_node("Panel/Stars/Star" + str(i+1))
		star_texture_rect.texture = STAR_FULL
		star_texture_rect.hint_tooltip = "Grown to Stage " + str(i+1)

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


func got_scanned(growth_stage: int):
	var sent_info = false
	if growth_stage >= 2:
		if not stage2_scanned:
			sent_info = true
			Game.UI.show_info_line("%s second Journal entry added" % plant_name, 3)
		stage2_scanned = true
	if growth_stage >= 3:
		if not stage3_scanned and not sent_info:
			sent_info = true
			Game.UI.show_info_line("%s third Journal entry added" % plant_name, 3)
		stage3_scanned = true
	if scanned == false and not sent_info:
		sent_info = true
		Game.UI.show_info_line("%s Journal entry added"  % plant_name, 3)
		
	scanned = true
#	$Panel.hint_tooltip = plant_profile.name
	$Panel.hint_tooltip = ""
	$Panel/Stars.visible = true
	$"%Preferences".visible = true
	$Panel/PlantIcon.anchor_left = anchor_left_scanned
	$Panel/PlantIcon.rect_scale = Vector2(1.0, 1.0)
