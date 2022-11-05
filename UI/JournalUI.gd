extends Control

# TODO later this JournalUI will be used in a ViewportTexture

var currently_hovering

func _ready() -> void:
	if not PlantData.plants_initiated_done:
		yield(PlantData, "plants_initiated")
	init()


func new_progress(plant_name:String, preference: PlantPreference):
	# TODO
	pass


func init():
	# later initializing these urself (maybe)
	var i = 1
	for plant_name in PlantData.profiles:
		var plant_ui: PlantUI = get_node("Control/PlantUI" + str(i))
		plant_ui.connect("clicked", self, "plant_clicked")
		i += 1
		plant_ui.plant_profile = PlantData.profiles[plant_name]
		for preference in PlantData.plant_profile_to_preference_list(plant_ui.plant_profile):
			preference = preference as PlantPreference
			plant_ui.add_preference(preference)

		plant_ui.plant_name = plant_name
	
func plant_clicked(plant_name):
	Game.multitool.get_node("Cooldown").start(0.6)
	Game.multitool.target_plant_name = plant_name
	Game.multitool.switch_to_tool(Game.multitool.TOOL.PLANT)
	Game.game_state = Game.State.INGAME

func plant_hovered(plant_ui):
	if currently_hovering != plant_ui:
		currently_hovering = plant_ui
		$"%HoverMarker".rect_global_position = plant_ui.rect_global_position - Vector2(11, 7)
		if not $HoverAnimation.is_playing():
			$HoverAnimation.play("hover")
			
		$"%Title".text = plant_ui.plant_profile.name
		$"%FluffText".text = plant_ui.plant_profile.fluff_base
		

func show():
	# TODO play show Journal animation (tool screen moving towards player cam basically)
	self.visible = true
	
	
func hide():
	self.visible = false

