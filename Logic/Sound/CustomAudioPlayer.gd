extends AudioStreamPlayer
class_name CustomAudioPlayer
	
var sound: ManagedSound
#var is_on_its_way_out := false

func _ready() -> void:
	pass

func play(start:=0.0):
#	if is_on_its_way_out:
#		print("playing but is on its way out")
#		return
	set_volume_db(sound.volume_db)
	set_bus(sound.mixer_bus)
	.play(start)


# seems nonsensical but gets used for tweening :)
func set_volume_linear(linear: float):
	self.volume_db = linear2db(linear)

func fade_in(start:=0.0, fade_duration:=1.0):
#	if is_on_its_way_out:
#		print("fading but is on its way out")
#		return
#	print(name + " fade_in")
	self.play(start)
	
	set_volume_db(-80.0)
	set_bus(sound.mixer_bus)
	var tween := get_tree().create_tween()
	tween.tween_method(self, "set_volume_linear", 0.0, db2linear(sound.volume_db), fade_duration)
	tween.play()

func reduce(amount: float, fade_duration:=0.4):
	# amount between 0.0 and 1.0
	var tween := get_tree().create_tween()
	tween.tween_method(self, "set_volume_linear", db2linear(volume_db), amount * db2linear(volume_db), fade_duration)
	tween.play()

func to_normal_vol(fade_duration:=0.4):
	var tween := get_tree().create_tween()
	tween.tween_method(self, "set_volume_linear", db2linear(volume_db), db2linear(sound.volume_db), fade_duration)
	tween.play()

func fade_out(fade_duration:=1.0):
#	print(name + " fade_out")
	var tween := get_tree().create_tween()
	tween.tween_method(self, "set_volume_linear", db2linear(volume_db), 0.0, fade_duration)
	tween.play()
	yield(tween, "finished")
#	is_on_its_way_out = true
	stop()
#	emit_signal("finished")

func _on_AudioPlayerWithInfo_finished() -> void:
#	print(sound.name, " finished")
	Audio.available.append(self)
	Audio.playing.erase(sound.name)
