tool
extends Spatial

export(int, 1, 3) var type := 0 setget set_type

func set_type(t : int):
	type = int(clamp(t, 1, 3))
	if Engine.editor_hint:
		change_model()

func _ready():
	change_model()

func change_model():
	$"stein1".visible = false
	$"stein2".visible = false
	$"stein3".visible = false
	if has_node("stein" + str(type)):
		get_node("stein" + str(type)).visible = true
	$StaticBody/CollisionShapeHigh.disabled = (type != 2)
