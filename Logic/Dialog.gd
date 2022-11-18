extends Node

export(Array, Resource) var lines: Array
export var voice_lv_db: float
var skipped = false

# 2 Types
# - Tutorialboxes (should be bound to Event-Singleton later probably)
# - Intro Voiced Lines


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
			return


func skip_intro():
	$Timer.wait_time = 0.01
	# could tween out if we're being really fancy :p
	$VoicedLinesPlayer.stop()
	Game.UI.get_node("DialogUI").hide_line()
	skipped = true
