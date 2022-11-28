extends Spatial

var plant: Plant

func setup():
	plant = get_parent()

func get_ability_tags():
	if plant.growth_stage >= PlantData.GROWTH_STAGES.STAGE_4:
		return ["sun_no"]
