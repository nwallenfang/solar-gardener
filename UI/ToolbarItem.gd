extends Control
tool

export var active := false setget set_active
export var deactive_mod: Color = Color("2e2e2e")
export var active_mod: Color = Color("ffffff")
export var hotkey: String setget set_hotkey

func _ready() -> void:
	$HotkeyBox/HotkeyLabel.text = hotkey
	
func set_active(new):
	active = new
	if active:
		if is_inside_tree():
			$Icon.modulate = active_mod
	else:
		if is_inside_tree():
			$Icon.modulate = deactive_mod


func set_hotkey(new: String):
	hotkey = new
	if is_inside_tree():
		$HotkeyBox/HotkeyLabel.text = hotkey

