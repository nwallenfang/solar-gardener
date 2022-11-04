extends AudioStreamPlayer
class_name AudioPlayerWithInfo
	
var sound: ManagedSound

func play(start:=0.0):
	set_volume_db(sound.volume_db)
	set_bus(sound.mixer_bus)
	.play(start)

func _on_AudioPlayerWithInfo_finished() -> void:
	Audio.available.append(self)
	Audio.playing.erase(self)
