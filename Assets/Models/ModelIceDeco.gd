tool
extends Spatial

export(int, 1, 4) var type := 0 setget set_type

func set_type(t : int):
	type = int(clamp(t, 1, 4))
	if Engine.editor_hint:
		change_model()

func _ready():
	change_model()

func change_model():
		$Ice001.visible = false
		$Ice002.visible = false
		$Ice003.visible = false
		$Ice004.visible = false
		if has_node("Ice00" + str(type)):
			get_node("Ice00" + str(type)).visible = true

