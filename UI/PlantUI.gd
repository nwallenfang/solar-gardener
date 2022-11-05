extends Control


const STAR_FULL = preload("res://Assets/Sprites/star-full.png")
const STAR_EMPTY = preload("res://Assets/Sprites/star-empty.png")

var plant_name
var number_of_stars setget set_number_of_stars

signal hovered(plant_name)
signal clicked(plant_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	plant_name




func get_data_for_plant(new_plant_name):
	self.plant_name = new_plant_name
	# GET ALL THE DATA FROM PlantData singleton
	self.number_of_stars = 2


func set_number_of_stars(number):
	number_of_stars = number
	
	# TODO update UI
	for i in range(number_of_stars):
		var star_texture_rect: TextureRect = get_node("Stars/Star" + str(i+1))
		star_texture_rect.texture = STAR_FULL
