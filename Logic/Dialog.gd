extends Node

export(Array, Resource) var lines: Array
export var voice_lv_db: float

# 2 Types
# - Tutorialboxes (should be bound to Event-Singleton later probably)
# - Intro Voiced Lines
func _ready() -> void:
	pass


func play_line(line: DialogLine, not_last_one:=true):
	$VoicedLinesPlayer.stream = line.audio
	$VoicedLinesPlayer.volume_db = line.level_db
	$VoicedLinesPlayer.play()
	var duration: float = $VoicedLinesPlayer.stream.get_length()
	Game.UI.show_line(line.text, duration + line.extra_duration, not_last_one)
	$Timer.start(duration + line.extra_duration)


func play_intro():
	var i = 0
	var number_of_lines = len(lines)
	for line in lines:
		i += 1 
		line = line as DialogLine
#		print("playing line " + line.text)

		# if last one the dialogs should be hidden after / different transition
		play_line(line, i != number_of_lines)
		yield($Timer, "timeout")
		


