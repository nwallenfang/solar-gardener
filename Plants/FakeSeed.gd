extends Spatial

export var scale_factor := .4

func setup(seed_name: String, second_scale_factor: float = 1.0):
	var profile: PlantProfile = PlantData.profiles[seed_name]
	var seed_model = profile.model_seed.instance() as Spatial
	for mi in Utility.get_all_mesh_instance_children(seed_model):
		mi.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF
	add_child(seed_model)
	seed_model.scale = Vector3.ONE * scale_factor * second_scale_factor
