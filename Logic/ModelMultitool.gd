extends Spatial

signal animation_finished
signal wheel_homed

# Slingshot Exports
export var update_slingshot := false
export var visibility_slingshot := 0.0


func set_hopper(active: bool):
	$HopperRings.set_active(active)
	$HopperPlayer.play("on" if active else "off")
	yield($HopperPlayer,"animation_finished")
	emit_signal("animation_finished")

func set_grow(active: bool):
	$GrowBeamPlayer.play("on" if active else "off")
	if active:
		wheel_accel_to(-100, 1.0)
	else:
#		Audio.play("growbeam_close")
		set_grow_beam_on_target(null)
		home_wheel()
	yield($GrowBeamPlayer,"animation_finished")
	emit_signal("animation_finished")

func set_plant(active: bool):
	$SlingshotPlayer.stop(true)
	$SlingshotPlayer.play("RESET")
	visibility_slingshot = 0.0
	$Slingshot.visible = false
	$SeedOrigin.visible = false
	if active:
		$Antenna.visible = false
	$PlantPlayer.play("on" if active else "off")
	if active and Game.game_state != Game.State.LOADING:
		Audio.play("seedgun_load")
	if not active:
		$Slingshot.visible = false
	yield(get_tree().create_timer(.1),"timeout")
	if active:
		home_wheel()
	yield($PlantPlayer,"animation_finished")
	if not active:
		$Antenna.visible = true
		$Slingshot.visible = false
		Audio.play("seedgun_close")
	$SeedOrigin.visible = active
	emit_signal("animation_finished")

func set_analysis(active: bool):
	$AnalysePlayer.play("on" if active else "off")
	$HopperPlayer.play("on" if active else "off")
	if active:
		Audio.play("scanner_open")
		Audio.play("scanner_rotate_slow")
		wheel_accel_to(80, 1.0)
	else:
		Audio.play("scanner_close")
		Audio.stop("scanner_rotate_slow")
		home_wheel()
	yield($AnalysePlayer,"animation_finished")
	emit_signal("animation_finished")

func seed_reload():
	$SeedOrigin.visible = false
	$SlingshotPlayer.play("reload")
	yield(get_tree(), "idle_frame")
	$SeedOrigin.visible = true
	yield($SlingshotPlayer,"animation_finished")
	emit_signal("animation_finished")

func seed_shot():
	$SlingshotPlayer.play("shot")
	yield($SlingshotPlayer,"animation_finished")
	emit_signal("animation_finished")

var death_color_active := false
var grow_beam_target: Spatial = null
var grow_beam_active: bool = false
func set_grow_beam_on_target(target: Spatial, death := false):
	grow_beam_active = (target != null)
	grow_beam_target = target
	$"%Beam1".visible = grow_beam_active
	$"%Beam2".visible = grow_beam_active
	$"%Beam3".visible = grow_beam_active
	$"%GrowBeam".visible = grow_beam_active
	$"%EnergyBallCombo".visible = grow_beam_active
	wheel_accel_to(-300 if grow_beam_active else -100, .4)
	if death != death_color_active:
		death_color_active = death
		var target_color: Color = $"%EnergyBallCombo".death_color if death else $"%EnergyBallCombo".grow_color
		$"%GrowBeam".material_override.set("shader_param/albedo", target_color)
		$"%EnergyBallCombo".set_death_color(death)
		$Wheel/ArmBase1/Arm1/ArmPoint1/EnergyBall.set_death_color(death)
		$Wheel/ArmBase2/Arm2/ArmPoint2/EnergyBall.set_death_color(death)
		$Wheel/ArmBase3/Arm3/ArmPoint3/EnergyBall.set_death_color(death)

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
			
	# Grow Beam Draw
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
	
	# Slingshot draw
	if update_slingshot:
		var vertex_list := []
		vertex_list.append($Wheel/ArmBase2/Arm2/ArmPoint2/SlingBall.global_translation)
		vertex_list.append($SeedOrigin/IGVertex1.global_translation)
		vertex_list.append($SeedOrigin/IGVertex2.global_translation)
		vertex_list.append($SeedOrigin/IGVertex3.global_translation)
		vertex_list.append($Wheel/ArmBase3/Arm3/ArmPoint3/SlingBall.global_translation)
		var global_offset := self.to_global(Vector3.ZERO).direction_to(self.to_global(Vector3.UP)) * .02
		var total_length := 0.0
		var length_segments := [0.0]
		for i in range(len(vertex_list) - 1):
			var dist :float= vertex_list[i].distance_to(vertex_list[i+1])
			total_length += dist
			length_segments.append(total_length)
		var ig : ImmediateGeometry = $Slingshot
		ig.material_override.set("shader_param/activation", visibility_slingshot)
		ig.visible = (visibility_slingshot > 0.1)
		ig.clear()
		ig.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in range(len(vertex_list) - 1):
			var point_a : Vector3 = vertex_list[i]
			var point_b : Vector3 = vertex_list[i+1]
			
			var uv_a : float = length_segments[i] / total_length
			var uv_b : float = length_segments[i+1] / total_length
			
			ig.set_uv(Vector2(uv_a, 0))
			ig.add_vertex(ig.to_local(point_a + global_offset))
			ig.set_uv(Vector2(uv_a, 1))
			ig.add_vertex(ig.to_local(point_a - global_offset))
			ig.set_uv(Vector2(uv_b, 0))
			ig.add_vertex(ig.to_local(point_b + global_offset))
			
			ig.set_uv(Vector2(uv_b, 0))
			ig.add_vertex(ig.to_local(point_b + global_offset))
			ig.set_uv(Vector2(uv_b, 1))
			ig.add_vertex(ig.to_local(point_b - global_offset))
			ig.set_uv(Vector2(uv_a, 1))
			ig.add_vertex(ig.to_local(point_a - global_offset))
			
		ig.end()
		

func wheel_accel_to(velocity: float, time: float):
	$WheelTween.stop_all()
	$WheelTween.remove_all()
	$WheelTween.interpolate_property(self, "wheel_velocity", wheel_velocity, velocity, time)
	$WheelTween.start()

func home_wheel():
	$WheelTween.stop_all()
	$WheelTween.remove_all()
	if abs(wheel_velocity) > 0.001:
		$WheelTween.interpolate_property(self, "wheel_velocity", wheel_velocity, 0.0, .5)
		$WheelTween.start()
		yield($WheelTween,"tween_all_completed")
		wheel_velocity = 0.0
	$WheelTween.interpolate_property($Wheel, "rotation_degrees:x", $Wheel.rotation_degrees.x, 90, .8,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
	$WheelTween.start()
	yield($WheelTween,"tween_all_completed")
	wheel_velocity = 0.0
	emit_signal("wheel_homed")

func set_holo_text(text: String):
	$HoloScreen.visible = (text != "")
	$HoloScreen.set_text(text)

func set_holo_visible(vis: bool):
	$HoloScreen.visible = vis

func _ready():
	var speed_factor := 1.3
	$HopperPlayer.playback_speed = speed_factor
	$GrowBeamPlayer.playback_speed = speed_factor
	$PlantPlayer.playback_speed = speed_factor
	$SlingshotPlayer.playback_speed = speed_factor
	$AnalysePlayer.playback_speed = speed_factor
