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
		wheel_accel_to(-100, 1.0)
	else:
		home_wheel()
	yield($GrowBeamPlayer,"animation_finished")
	emit_signal("animation_finished")

var grow_beam_target: Spatial = null
var grow_beam_active: bool = false
func set_grow_beam_on_target(target: Spatial):
	grow_beam_active = (target != null)
	grow_beam_target = target
	$"%Beam1".visible = grow_beam_active
	$"%Beam2".visible = grow_beam_active
	$"%Beam3".visible = grow_beam_active
	$"%GrowBeam".visible = grow_beam_active
	$"%EnergyBallCombo".visible = grow_beam_active
	wheel_accel_to(-300 if grow_beam_active else -100, .4)

var wheel_velocity := 0.0

func _physics_process(delta):
	# Wheel Animation
	if abs(wheel_velocity) > 0.01:
		$Wheel.rotation_degrees.y = 90
		$Wheel.rotation_degrees.z = 90
		$Wheel.rotation_degrees.x += wheel_velocity * delta
		if $Wheel.rotation_degrees.x < -90:
			$Wheel.rotation_degrees.x += 360
		elif $Wheel.rotation_degrees.x > 270:
			$Wheel.rotation_degrees.x -= 360
	# Grow Beam Drawl
	if grow_beam_active:
		var origin : Vector3 = $GrowBeamOrigin.global_translation
		var offset : Vector3 = $"%GrowBeamDirectionOffset".global_translation - $GrowBeamOrigin.global_translation
		var target : Vector3 = grow_beam_target.global_translation
		var ig : ImmediateGeometry = $"%GrowBeam"
		ig.clear()
		ig.begin(Mesh.PRIMITIVE_TRIANGLES)
		
		ig.set_uv(Vector2(1, 0))
		ig.add_vertex(ig.to_local(origin + offset))
		ig.set_uv(Vector2(1, 1))
		ig.add_vertex(ig.to_local(origin - offset))
		ig.set_uv(Vector2(0, 0))
		ig.add_vertex(ig.to_local(target + offset))
		
		ig.set_uv(Vector2(0, 0))
		ig.add_vertex(ig.to_local(target + offset))
		ig.set_uv(Vector2(0, 1))
		ig.add_vertex(ig.to_local(target - offset))
		ig.set_uv(Vector2(1, 1))
		ig.add_vertex(ig.to_local(origin - offset))
		
		ig.end()

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
