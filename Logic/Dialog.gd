extends Node

export(String, MULTILINE) var note_text1: String
export(String, MULTILINE) var note_text2: String
export(String, MULTILINE) var note_text3: String

export var note_audio1: AudioStreamOGGVorbis
export var note_audio2: AudioStreamOGGVorbis
export var note_audio3: AudioStreamOGGVorbis

export(Array, Resource) var lines: Array
export var voice_lv_db: float
var skipped = false

var _next_index = 1

func play_line(line: DialogLine, not_last_one:=true):
	$VoicedLinesPlayer.stream = line.audio
	$VoicedLinesPlayer.volume_db = line.level_db
	$VoicedLinesPlayer.play()
	var duration: float = $VoicedLinesPlayer.stream.get_length()
	Game.UI.show_line(line.text, duration + line.extra_duration, not_last_one)
	$Timer.start(duration + line.extra_duration)


func play_intro():
	yield(get_tree().create_timer(1.5), "timeout")
	
	var i = 0
	var number_of_lines = len(lines)
	for line in lines:
		i += 1 
		line = line as DialogLine

		# if last one the dialogs should be hidden after / different transition
		play_line(line, i != number_of_lines)
		yield($Timer, "timeout")
		if skipped:
#			yield(get_tree().create_timer())
			return
			
	yield(get_tree().create_timer(3.5), "timeout")
	Events.tutorial_beginning()

func get_next_index():
	_next_index += 1
	return _next_index-1

func get_gardener_note(index: int) -> String:
	return get("note_text" + str(index))
	

func play_gardener_voice_over(index: int):
	var stream = get("note_audio" + str(index))
	$VoiceOver.stream = stream
	$VoiceOver.play()
	if Game.planet.planet_growth_stage > 0:
		Audio.reduce_volume(Game.planet.get_current_music_name(), 0.4)

func _on_VoiceOver_finished() -> void:
	if Game.planet.planet_growth_stage > 0:
		Audio.to_normal_volume(Game.planet.get_current_music_name())

func skip_intro():
	$Timer.wait_time = 0.01
	# could tween out if we're being really fancy :p
	$VoicedLinesPlayer.stop()
	Game.UI.get_node("DialogUI").hide_line()
	skipped = true



