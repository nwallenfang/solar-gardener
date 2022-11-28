extends Spatial

var plant: Plant

func setup():
	plant = get_parent()

func _on_ProcessTimer_timeout():
	if plant.growth_stage == PlantData.GROWTH_STAGES.STAGE_4:
		for obj in plant.get_near_symbiosis_objects_list():
			if obj.name == "Ice":
				obj.get_parent().melt()

func get_ability_tags():
	return ["sun_yes"]
