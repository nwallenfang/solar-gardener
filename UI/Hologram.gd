extends Control
class_name Hologram

export var special_color: Color = Color("5b56ac")
export var default_color: Color = Color("51b19b")

var current_screen: Control

func _ready() -> void:
	Game.hologram = self
	for control in $AspectRatioContainer.get_children():
		control.visible = false
#	$AspectRatioContainer/BackgroundPanel.visible = true

func _physics_process(delta):
	if is_instance_valid(Game.multitool) and is_instance_valid(current_screen):
		Game.multitool.set_holo_visible(current_screen.visible)

func clear():
	if current_screen != null:
		current_screen.visible = false

# Called when the node enters the scene tree for the first time.
func set_text(text: String):
	$"%Label".text = text


# seed name + seedcount, scan name + scan progress, soil analysis (planet)
func show_soil_info(planet_name: String, type_name: String, has_nutrients:bool, is_close_to_sun: bool):
	if current_screen != null:
		current_screen.visible = false
	$"%SoilInfo".visible = true
	
	current_screen = $"%SoilInfo"
	
	$"%PlanetName".text = planet_name
	$"%PlanetType".text = type_name
	if has_nutrients:
		$"%HasNutrients".text = "has Nutrients"
	else:
		$"%HasNutrients".text = "no Nutrients"
	if is_close_to_sun:
		$"%HasNutrients".text = "Close to Sun"
	else:
		$"%CloseToSun".text = "Far from Sun"

func show_hop_info(planet_name):
	if current_screen != null:
		current_screen.visible = false
	$"%PlanetHop".visible = true
	$"%HopLabel".text = planet_name
	current_screen = $"%PlanetHop"


func grow_beam_juice(beam_active: bool, juice_left: float, plant_growing:=true):
	# grow beam hologram in other color?
	if current_screen != null:
		current_screen.visible = false
	$"%GrowBeam".visible = true
	current_screen = $"%GrowBeam"
	
	if beam_active and plant_growing:
		$"%IsGrowingLabel".text = "growing.."
	else:
		$"%IsGrowingLabel".text = ""
	$"%JuiceLeft".text = str(int(juice_left*100.0)) + "%"


func show_plant_info(plant_name: String, plant_type: String, growth_stage: int, is_growing: bool):
	if current_screen != null:
		current_screen.visible = false
	$"%PlantInfo".visible = true
	current_screen = $"%PlantInfo"
	
	$"%PlantName".text = plant_name
	$"%PlantType".text = plant_type
	$"%GrowthStage".text = str(growth_stage-1)
	if is_growing:
		$"%CurrentlyGrowing".text = "growing"
	else:
		$"%CurrentlyGrowing".text = "not growing"
	
func show_seed_info(seed_name: String, seed_count: int):
	if current_screen != null:
		current_screen.visible = false
	$"%SeedInfo".visible = true
	current_screen = $"%SeedInfo"
	
	$"%SeedPlantName".text = seed_name
	$"%SeedCount".text = str(seed_count)

func show_scan_progress(object_name: String, progress: float):
	if current_screen != null:
		current_screen.visible = false
	$"%ScanProgress".visible = true
	current_screen = $"%ScanProgress"
	
	$"%ScanObjectName".text = object_name
	$"%ScanProgressLabel".text = "%d%%" % int(progress)
	
func show_analyse_info(text: String):
	# allrounder method that gets used atm instead of show_scan_progress and stuff
	# TODO split into different parts later
	
	$"%ScanHoverLabel".text = text
	
	if current_screen != null:
		current_screen.visible = false
	$"%ScanHover".visible = true
	current_screen = $"%ScanHover"
