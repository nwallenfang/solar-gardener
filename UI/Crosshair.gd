extends Control
class_name Crosshair
tool

enum Style { DEFAULT, SCANNER, ACTION, HOP, PLANT}
export(Style) var style = Style.DEFAULT setget set_style
onready var active_crosshair_sprite: Node = $"%CrosshairDefault"


onready var sprites = {
	Style.DEFAULT: $"%CrosshairDefault",
	Style.SCANNER: $"%CrosshairScanner",
	Style.ACTION:  $"%CrosshairAction",
	Style.HOP: $"%CrosshairHop",
	Style.PLANT: $"%CrosshairPlant",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("CrosshairScanner")
	Game.crosshair = self


func set_style(new_style: int):
	if active_crosshair_sprite != null:
		active_crosshair_sprite.visible = false

	# TODO replace with styles
	match new_style:
		Style.DEFAULT:
			active_crosshair_sprite = $"%CrosshairDefault"
		Style.SCANNER:
			active_crosshair_sprite = $"%CrosshairScanner"
		Style.ACTION:
			active_crosshair_sprite = $"%CrosshairAction"
		Style.HOP:
			active_crosshair_sprite = $"%CrosshairHop"
		Style.PLANT:
			active_crosshair_sprite = $"%CrosshairPlant"
	
	active_crosshair_sprite.visible = true
