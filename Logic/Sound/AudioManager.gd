extends Node

# IMPORTANT NOTE: this is dangerous, I can't even explain it properly, see this thread
# guide: https://github.com/godotengine/godot/issues/25672#issuecomment-461541415
export var sound_directoy = "res://Assets/Sound"

var num_players = 32

var available = []  # The available players, instances of type AudioPlayerWithInfo
var queue = []  # The queue of sounds to play.
var playing = [] # The players that are currently active, indexed by the sound name

var MANAGED_SOUND_SCENE = preload("res://Logic/Sound/ManagedSound.tscn")
var AUDIO_PLAYER_WITH_INFO = preload("res://Logic/Sound/AudioPlayerWithInfo.tscn")

func _ready():
	# Generate as many audio players as said in the variable
	for i in num_players:
		var audio_player_with_info = AUDIO_PLAYER_WITH_INFO.instance()
		$Players.add_child(audio_player_with_info, true)
		available.append(audio_player_with_info)

	var dir = Directory.new()
	if dir.open(sound_directoy) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			print(file_name)
			if file_name.ends_with(".ogg") or (OS.has_feature("standalone") and file_name.ends_with(".import")):
				if OS.has_feature("standalone"):  # hack -> see first comment of this file
					file_name = file_name.split(".import")[0]
					print("good")
				var node_name = file_name.split(".")[0]
				print("Loaded ", file_name)
				if not $Sounds.has_node(node_name): # sound has no custom config in Sounds
					var managed_sound = MANAGED_SOUND_SCENE.instance()
					managed_sound.name = node_name
					managed_sound.stream = load("res://Assets/Sound/" + file_name)
					$Sounds.add_child(managed_sound, true)
				else: # sound exists in Sounds
					var managed_sound = $Sounds.get_node(node_name)
					managed_sound.stream = load("res://Assets/Sound/" + file_name)
			file_name = dir.get_next()
	else:
		print("An error encountered loading the sounds")
	
func play(sound_name: String):
	queue.append(sound_name)

func stop(sound_name: String):
	for player_with_info in playing:
		if player_with_info.sound.name == sound_name:
			player_with_info.stop()
#
func set_volume(sound_name, volume):
	for player_with_info in playing:
#		print(stream_tuple.sound.file_name)
		if player_with_info.sound.name == sound_name:
			player_with_info.set_volume_db(volume)
#
func _process(delta):
#	# Play a queued sound if any players are available.
	if not queue.empty() and not available.empty():
		var sound_name = queue.pop_front()
		var player = available.pop_front()
		# Reset all player variables

		player.stream = $Sounds.get_node(sound_name).stream
		player.sound = $Sounds.get_node(sound_name)
		player.play()
		playing.append(player)
