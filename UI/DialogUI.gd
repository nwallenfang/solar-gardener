extends Control
class_name DialogUI

export var seeds_unlocked_color: Color
export var plant_unlocked_color: Color
export var plant_scanned_color: Color
export var preference_unlocked_color: Color

export var linger_time: float
export var float_time: float

const SUBTITLE_TEXT = preload("res://UI/SubtitleText.tscn")

enum INFO {
	MORE_SEEDS,
	PLANT_PREFERENCE,
	PLANT_UNLOCKED,
	PLANT_SCANNED,
}

var screen_height
var beginning_pos

func _ready() -> void:
	beginning_pos = $"%SubtitleText".rect_position
	PlantData.connect("got_seeds", self, "got_seeds")

var queue = []
var showing := false
func push_infoline(text: String, type: int):
	queue.append([text, type])
	
	if not showing:
		print("start showing")
		show_infoline()

var delay = 0.3
var i = 0
var offset_pct = 0.02
func show_infoline():
	var subtitle_text = SUBTITLE_TEXT.instance()
	add_child(subtitle_text)
	showing = true
	# dirty coding, sorry :(
	i +=1

	subtitle_text.modulate.a = 0.0
	screen_height = Game.main_scene.get_node("ViewportContainer/Viewport").size.y
	subtitle_text.rect_position = beginning_pos
	subtitle_text.rect_position.y -= (i % 3) * offset_pct * screen_height
	var line = queue.pop_front()
	print("start_pos: ", subtitle_text.rect_position)
	subtitle_text.text = line[0]
	match line[1]:  # (type of info, see enum)
		INFO.MORE_SEEDS:
			subtitle_text.set("custom_colors/font_color", seeds_unlocked_color)
		INFO.PLANT_PREFERENCE:
			subtitle_text.set("custom_colors/font_color", preference_unlocked_color)
		INFO.PLANT_UNLOCKED:
			subtitle_text.set("custom_colors/font_color", plant_unlocked_color)
		INFO.PLANT_SCANNED:
			subtitle_text.set("custom_colors/font_color", plant_scanned_color)
		
	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property(subtitle_text, "modulate:a", 1.0, 0.3)
	var target_position = subtitle_text.rect_position - 0.05 * Vector2(0.0, 1.0) * screen_height
	tween.chain().tween_property(subtitle_text, "rect_position", target_position, float_time).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(subtitle_text, "modulate:a", 0.0, linger_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.play()
	print("target_pos: ", target_position)
#	yield(get_tree().create_timer(delay), "timeout")
	if not queue.empty():
		show_infoline()
	else:
		showing = false
	yield(tween, "finished")
#	subtitle_text.rect_position = beginning_pos
	subtitle_text.queue_free()
#	if not queue.empty():
#		show_infoline()
#	else:
#		showing = false
		
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

func got_seeds(plant_name: String, amount: int, is_amber: bool):
	var seed_string: String = "+ %d %s seed" % [amount, plant_name]
	if amount > 1:
		seed_string += "s"
	
	if is_amber or (not Game.journal.get_got_scanned(plant_name)):  # i know i know so complicated just for this small detail
		push_infoline("+1 Unknown Seed", INFO.MORE_SEEDS)
	else:
		push_infoline(seed_string, INFO.MORE_SEEDS)

