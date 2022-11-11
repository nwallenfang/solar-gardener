extends Node

export(Array, Resource) var lines: Array
export var voice_lv_db: float

# 2 Types
# - Tutorialboxes (should be bound to Event-Singleton later probably)
# - Intro Voiced Lines
func _ready() -> void:
	pass


func play_line(line: DialogLine):
	$VoicedLinesPlayer.stream = line.audio
	$VoicedLinesPlayer.volume_db = line.level_db
	$VoicedLinesPlayer.play()
	var duration: float = $VoicedLinesPlayer.stream.get_length()
	Game.UI.show_line(line.text, duration + line.extra_duration)
	$Timer.start(duration + line.extra_duration)


func play_intro():
	for line in lines:
		line = line as DialogLine
		play_line(line)
		yield($Timer, "timeout")

