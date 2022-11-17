extends Spatial

export var SKY_ENERGY_HTML5 := 0.04
export var SKY_ENERGY_NATIVE := 0.5

func _ready() -> void:
	if OS.has_feature("HTML5"):
		$WorldEnvironment.environment.background_energy = SKY_ENERGY_HTML5
	else:
		$WorldEnvironment.environment.background_energy = SKY_ENERGY_NATIVE
	
	Game.world = self
	
	PlantData.setup()
	PlantData.add_test_progress()
	Game.sun = $Sun
	for c in get_children():
		if c is Planet:
			(c as Planet).setup()
	
	Game.planet = $Planet  # this is the starting planet
	Game.planet.set_player_is_on_planet(true)
	
	start_loading()

var INTRO_LENGTH_FACTOR = 3.0
var TEST_LENGTH_FACTOR = 0.05
const TEST_INTRO = false
func start_loading():
	if OS.is_debug_build() and (not TEST_INTRO):
		INTRO_LENGTH_FACTOR = TEST_LENGTH_FACTOR
	yield(get_tree(),"idle_frame")
	Game.UI.get_node("BlackScreen").visible = true
	Game.camera.current = false
	var loading_cams :Array = $LoadingCams.get_children()
	for i in range(len(loading_cams)):
		var cam: Camera = loading_cams[i]
		cam.current = true
		if cam.has_node("Ubershader"):
			cam.get_node("Ubershader").activate()
		yield(get_tree().create_timer(.2),"timeout")
		cam.current = false
		cam.queue_free()
		Game.UI.set_loading_bar(float(i)/len(loading_cams))
	Game.UI.set_loading_bar(1.0)
	yield(get_tree().create_timer(.3), "timeout")
	start_intro_flight()

func get_four_percent_values(offset: float) -> Array:
	var values := [0.0, 0.25, 0.25, 0.0]
	values[0] += lerp(.25, .0, offset)
	values[1] += lerp(.25, .0, offset)
	values[2] += lerp(.0, .25, offset)
	values[3] += lerp(.0, .25, offset)
	return values

var intro_cams := []
export var intro_flight_offset : float setget set_flight_offset
func set_flight_offset(x: float):
	if Game.game_state == Game.State.INTRO_FLIGHT:
		x = clamp(x, 0.0, float(len(intro_cams)))
		var progress : float = fmod(x, 1.0)
		var index : int = int(round(x - progress))
		var cam_a : Camera = intro_cams[index]
		if index == len(intro_cams) - 1:
			$IntroFlight/FlyCamera.global_transform = cam_a.global_transform
		else:
			var cam_b : Camera = intro_cams[index + 1]
			var cam_0 : Camera = cam_a
			if index - 1 >= 0:
				cam_0 = intro_cams[index - 1]
			var cam_1 : Camera = cam_b
			if index + 2 < len(intro_cams):
				cam_1 = intro_cams[index + 2]
			#$IntroFlight/FlyCamera.global_transform = cam_a.global_transform.interpolate_with(cam_b.global_transform, progress)
			var lerp_weights : Array = Utility.get_multi_lerp_weights(get_four_percent_values(progress))
			var target_transform : Transform = cam_0.global_transform.interpolate_with(cam_a.global_transform, lerp_weights[0])
			target_transform = target_transform.interpolate_with(cam_b.global_transform, lerp_weights[1])
			target_transform = target_transform.interpolate_with(cam_1.global_transform, lerp_weights[2])
			$IntroFlight/FlyCamera.global_transform = target_transform

func start_intro_flight():
	Game.set_game_state(Game.State.INTRO_FLIGHT)
	if (not OS.is_debug_build()) or TEST_INTRO:
		Dialog.play_intro()
	else:
		Game.UI.get_node("DialogUI/Controls/SubtitleText").text = ""
	
	Game.multitool.visible = false
	
	for i in range(7):
		intro_cams.append(get_node("IntroFlight/Camera" + str(i)))
	intro_cams.append(Game.camera)
	intro_cams.append(Game.camera)
	
	$"%FlyCamera".current = true
	$IntroFlight/Tween.interpolate_method(Game.UI, "set_blackscreen_alpha", 1.0, 0.0, 1.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$IntroFlight/Tween.start()
	$IntroFlight/AnimationPlayer.playback_speed = 1.0 / INTRO_LENGTH_FACTOR
	$IntroFlight/AnimationPlayer.play("fly")
	yield($IntroFlight/AnimationPlayer, "animation_finished")
	Game.UI.get_node("BlackScreen").visible = false
	$"%FlyCamera".current = false
	Game.camera.current = true
	
	yield(get_tree().create_timer(1),"timeout")
	Game.player.update_look_direction()
	Game.set_game_state(Game.State.INGAME)
	Game.multitool.visible = true

	yield(get_tree().create_timer(2.0), "timeout")
	Events.tutorial_beginning()
