extends Control
class_name DialogUI

export var seeds_unlocked_color: Color
export var plant_unlocked_color: Color
export var preference_unlocked_color: Color

export var linger_time: float
export var float_time: float

enum INFO {
	MORE_SEEDS,
	PLANT_PREFERENCE,
	PLANT_UNLOCKED,
}

var screen_height
var beginning_pos

func _ready() -> void:
	beginning_pos = $"%SubtitleText".rect_position

var queue = []
var showing := false
func push_infoline(text: String, type: int):
	queue.append([text, type])
	
	if not showing:
		print("start showing")
		show_infoline()

func show_infoline():
	showing = true
	# dirty coding, sorry :(
	beginning_pos = $"%SubtitleText".rect_position
	$"%SubtitleText".modulate.a = 0.0
	screen_height = Game.main_scene.get_node("ViewportContainer/Viewport").size.y
	var line = queue.pop_front()
	$Controls/SubtitleText.text = line[0]
	match line[1]:  # (type of info, see enum)
		INFO.MORE_SEEDS:
			$Controls/SubtitleText.set("custom_colors/font_color", seeds_unlocked_color)
		INFO.PLANT_PREFERENCE:
			$Controls/SubtitleText.set("custom_colors/font_color", preference_unlocked_color)
		INFO.PLANT_UNLOCKED:
			$Controls/SubtitleText.set("custom_colors/font_color", plant_unlocked_color)
		
	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property($"%SubtitleText", "modulate:a", 1.0, 0.4)
	var target_position = $"%SubtitleText".rect_position - 0.05 * Vector2(0.0, 1.0) * screen_height
	tween.chain().tween_property($"%SubtitleText", "rect_position", target_position, linger_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($"%SubtitleText", "modulate:a", 0.0, linger_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	yield(tween, "finished")
	$"%SubtitleText".rect_position = beginning_pos
	
	if not queue.empty():
		show_infoline()
	else:
		showing = false
		
func hide_line():
	$"%SubtitleText".text = ""


func show_dialogline(text: String, duration: float, another_one_coming:=false):
	# TODO play show animation
	$"%SubtitleText".text = text
	# TODO play hide animation
	# TODO if another one is coming up the text shouldn't fade out completely
	# or smth
	if not another_one_coming:
		yield(get_tree().create_timer(duration), "timeout")
		$"%SubtitleText".text = ""
