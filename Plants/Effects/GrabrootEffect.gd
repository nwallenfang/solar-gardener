extends Spatial

var plant: Plant

func setup():
	plant = get_parent()

var occur_range := 5.0

func _on_ProcessTimer_timeout():
	if plant.planet.has_been_grab_rooted:
		$ProcessTimer.stop()
		return
	if plant.growth_stage == PlantData.GROWTH_STAGES.STAGE_2:
		var random_local_point_in_air := Vector3.UP * 3.0
		random_local_point_in_air.x = (randf()-.5) * 2.0 * occur_range
		random_local_point_in_air.z = (randf()-.5) * 2.0 * occur_range
		var global_pos := Utility.get_planet_surface_point_from_pos(plant.planet, to_global(random_local_point_in_air))
		plant.planet.try_grabroot_effect(global_pos)
