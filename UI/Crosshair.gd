extends Control
class_name Crosshair
tool

enum Style { DEFAULT, SCANNER, ACTION, HOP }
export(Style) var style = Style.DEFAULT setget set_style

onready var sprites = {
	Style.DEFAULT: $"%CrosshairDefault",
	Style.SCANNER: $"%CrosshairScanner",
	Style.ACTION:  $"%CrosshairAction",
	Style.HOP: $"%CrosshairHop",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.crosshair = self


func set_style(new_style: int):
	match new_style:
		Style.DEFAULT:
			pass
		Style.SCANNER:
			pass
		Style.ACTION:
			pass
	
	
