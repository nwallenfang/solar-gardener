extends Spatial

signal animation_finished
signal wheel_homed

func set_hopper(active: bool):
	$HopperRings.set_active(active)
	$HopperPlayer.play("on" if active else "off")
	yield($HopperPlayer,"animation_finished")
	yield(get_tree().create_timer(.1),"timeout")
	emit_signal("animation_finished")

func set_grow(active: bool):
	$GrowBeamPlayer.play("on" if active else "off")
	if active:
		wheel_accel_to(160, 1.0)
	else:
		home_wheel()
	yield($GrowBeamPlayer,"animation_finished")
	emit_signal("animation_finished")

var wheel_velocity := 0.0

func _physics_process(delta):
	if abs(wheel_velocity) > 0.01:
		$Wheel.rotation_degrees.x += wheel_velocity * delta
		if $Wheel.rotation_degrees.x < -90:
			$Wheel.rotation_degrees.x += 360
		elif $Wheel.rotation_degrees.x > 270:
			$Wheel.rotation_degrees -= 360

func wheel_accel_to(velocity: float, time: float):
	$WheelTween.stop_all()
	$WheelTween.remove_all()
	$WheelTween.interpolate_property(self, "wheel_velocity", wheel_velocity, velocity, time)
	$WheelTween.start()

func home_wheel():
	$WheelTween.stop_all()
	$WheelTween.remove_all()
	if abs(wheel_velocity) > 0.01:
		$WheelTween.interpolate_property(self, "wheel_velocity", wheel_velocity, 0.0, .5)
		$WheelTween.start()
		yield($WheelTween,"tween_all_completed")
	$WheelTween.interpolate_property($Wheel, "rotation_degrees:x", $Wheel.rotation_degrees.x, 90, .8,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
	$WheelTween.start()
	yield($WheelTween,"tween_all_completed")
	emit_signal("wheel_homed")
