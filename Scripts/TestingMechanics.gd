extends Node2D
class_name TestingMechanics

@export var enable_audio: bool = false: # Checkbox to enable/disable audio in testing
	set(value):
		enable_audio = value
		if is_inside_tree():
			_configure_audio_for_testing()

func _ready() -> void:
	# Disable all audio in testing scene by default
	_configure_audio_for_testing()

func _configure_audio_for_testing() -> void:
	# Simply mute/unmute the Master audio bus
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus_idx, not enable_audio)
