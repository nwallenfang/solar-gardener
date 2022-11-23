extends Control
class_name JournalUI

var currently_hovering

func _ready() -> void:
	PlantData.connect("seeds_updated", self, "seed_count_updated")
	PlantData.connect("growth_stage_reached", self, "growth_staged_reached")
	if not PlantData.plants_initiated_done:
		yield(PlantData, "plants_initiated")
	init()
	Game.journal = self


func init():
	var i = 1
	var profile_names_abc = PlantData.profiles.keys().duplicate()
	profile_names_abc.sort()
	for plant_name in profile_names_abc:
		var plant_ui: PlantUI = get_node("GridContainer/PlantUI" + str(i))
		plant_ui.connect("clicked", self, "plant_clicked")
		plant_ui.connect("plant_got_hovered", self, "plant_hovered")
		i += 1
		plant_ui.plant_profile = PlantData.profiles[plant_name]
		for preference in PlantData.plant_profile_to_preference_list(plant_ui.plant_profile):
			preference = preference as PlantPreference
			plant_ui.add_preference(preference)
			plant_ui.name = "PlantUI" + plant_name

		plant_ui.plant_name = plant_name
	
func plant_clicked(plant_name):
	Audio.play("ui2")
	#Game.multitool.get_node("Cooldown").start(0.6)
	Game.multitool.target_plant_name = plant_name
	Game.multitool.switch_tool(Game.multitool.TOOL.PLANT)
	Game.multitool.show_plant_information()
	Game.multitool.force_reload = true
	Game.game_state = Game.State.INGAME
	$"%HoverMarker".visible = false
#		currently_hovering.hovered = false
#		currently_hovering = null


export(String, MULTILINE) var not_scanned_yet_fluff
func plant_hovered(plant_ui: PlantUI):
	if plant_ui.discovered:
		currently_hovering = plant_ui
		$"%HoverMarker".visible = true
		$"%HoverMarker".rect_global_position = plant_ui.rect_global_position - Vector2(12, 1)
		if not $HoverAnimation.is_playing():
			$HoverAnimation.play("hover")
		
		if plant_ui.scanned:
			# TODO different stages of fluff text depending on progress
			$"%Title".text = plant_ui.plant_profile.name
			$"%FluffText".bbcode_text = plant_ui.plant_profile.fluff_base
			if plant_ui.number_of_stars >= 1:
				if plant_ui.stage2_scanned:
					$"%FluffText".bbcode_text += "\n" + plant_ui.plant_profile.fluff_stage2
				else:
					$"%FluffText".bbcode_text += "\n[Scan further grown plant to unlock more]"
					
			if plant_ui.number_of_stars >= 2:
				if plant_ui.stage3_scanned:
					$"%FluffText".bbcode_text += "\n" + plant_ui.plant_profile.fluff_stage3
				else:
					if plant_ui.stage2_scanned:
						$"%FluffText".bbcode_text += "\n[Scan further grown plant to unlock more]"
				
		else:
			$"%Title".text = "???"
			$"%FluffText".bbcode_text = not_scanned_yet_fluff

func seed_count_updated(plant_name, total_seeds):
	var plant_ui: PlantUI = get_node("GridContainer/PlantUI" + plant_name)
	plant_ui.set_seed_count(total_seeds)

func growth_staged_reached(plant_name, growth_stage):
	var plant_ui: PlantUI = get_node("GridContainer/PlantUI" + plant_name)
	if growth_stage > plant_ui.number_of_stars:
		plant_ui.set_number_of_stars(growth_stage)

func make_preference_known(plant_name: String, plant_preference_name: String):
	# find plant ui belonging to this plant
	for plant_ui in get_tree().get_nodes_in_group("plant_ui"):
		if plant_ui.plant_name == plant_name:
			plant_ui.make_preference_known(plant_preference_name)

func make_preference_list_known(plant_name: String, plant_references: Array):
	# practical to save on for loops pls use this!
	# TODO
	printerr("TODO list_known")


func show():
	if currently_hovering != null:
		plant_hovered(currently_hovering)

func hide():
#	$"%HoverMarker".visible = false
#	if currently_hovering != null:
#		currently_hovering.hovered = false
#		currently_hovering = null
	pass

var scanned_plant_names := []
func plant_got_scanned(plant_name: String, growth_stage: int):
	# wait a little cuz lots of other stuff might be happening already
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	scanned_plant_names.append(plant_name)
	
	for plant_ui in get_tree().get_nodes_in_group("plant_ui"):
		if plant_ui.plant_name == plant_name:
			plant_ui.got_scanned(growth_stage)


# delete?
#const fluff_text_res: DynamicFont = preload("res://Assets/Fonts/FluffText.tres")
#onready var ratio = fluff_text_res.extra_spacing_bottom / get_viewport().size.y
#func root_viewport_size_changed():
##	print("heyooo")
##	var size = get_viewport().size.y
##	var fluff_text: DynamicFont = $"%FluffText".get("custom_fonts/normal_font")
##	fluff_text.extra_spacing_bottom = int(size * ratio + 0.5)
##	$"%FluffText".text = $"%FluffText".text
#	pass
	
