extends Node  # TODO this should be a Resource, not a Node
class_name ManagedSound, "res://Assets/Sprites/managed_sound.png"

var stream: AudioStreamOGGVorbis
var current_offset: float

export var volume_db := 0.0
export var mixer_bus := "Master"
# max_distance only 
export var max_distance_when_attenuated := 10.0

# volume, bus?, transition types/durations
