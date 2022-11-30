extends Control



func _ready() -> void:
	$Panel/VBoxContainer/BenchmarkContainer.visible = OS.is_debug_build() 
	$Panel/VBoxContainer/MusicVolumeH/MusicSlider.value = db2linear(AudioServer.get_bus_volume_db(1))
	$Panel/VBoxContainer/SFXVolumeH/SFXSlider.value = db2linear(AudioServer.get_bus_volume_db(2))
	
	if OS.is_debug_build():
		$Panel/VBoxContainer/BenchmarkContainer.visible = true


func determine_git_hash() -> String:
	var commit_id_output = [] 
	var project_dir = ProjectSettings.globalize_path("res://")
	var args = ["-C", project_dir, "log", "--pretty=format:'%h'", "-n 1"]
#	var args_test = ["-C",  project_dir, "status"]

	var exit_code = OS.execute("git", args, true, commit_id_output, true)
	
	if exit_code != 0:
		return "git-error"
	else:
		return commit_id_output[0]

func save_benchmark(metadata: String):
	var benchmark := File.new()
	benchmark.open("res://benchmarks.txt", File.READ_WRITE)
	
	var time_string = Time.get_date_string_from_system() + " " + Time.get_time_string_from_system()
	var commit_hash = determine_git_hash()
	var level = "main_world"
	var avg_fps = "%.2f" % Game.UI.get_node("Diagnostics").average_fps
	
	benchmark.seek_end()
	benchmark.store_line("[%s, %s], %s, info: %s, fps: %s" % [time_string, commit_hash, level, metadata, avg_fps])
	benchmark.close()


func _on_SaveFPSButton_pressed() -> void:
	save_benchmark($"%Metadata".text)


onready var metadata_default_text = $"%Metadata".text
func _on_Metadata_focus_entered() -> void:
	if $"%Metadata".text == metadata_default_text:
		$"%Metadata".text = ""

func _on_SensitivitySlider_value_changed(value: float) -> void:
	Game.player.mouse_sensitivity = (Game.player.min_sensitivity + value * (Game.player.max_sensitivity - Game.player.min_sensitivity))



func hide_settings():
	self.visible = false
	
func show_settings():
	self.visible = true

func _on_DoneButton_pressed():
	Game.get_node("SettingsOpenCooldown").start(0.4)
	Game.game_state = Game.State.INGAME


func _on_MusicSlider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear2db(value))


func _on_SFXSlider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear2db(value))


func _on_InvertYButton_pressed() -> void:
	Game.player.y_axis_factor = -Game.player.y_axis_factor


func _on_GraphicsSlider_value_changed(value: float) -> void:
	value = lerp(.3, 1.0, value)
	Game.world.get_node("Stars").visible = (value >= .7)
	for planet in Game.planet_list:
		planet = planet as Planet
		planet.render_multi_mesh = (value >= .7)
	Game.planet.trigger_lod(false)
	Game.main_scene.resolution_scaling_factor = value
	Game.main_scene.root_viewport_size_changed()
