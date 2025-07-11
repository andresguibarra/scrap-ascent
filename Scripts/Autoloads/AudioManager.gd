extends Node

var audio_player: AudioStreamPlayer

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.name = "GlobalAudioPlayer"
	add_child(audio_player)

func play_sound(sound: AudioStream, volume_db: float = 0.0) -> void:
	if sound and audio_player:
		audio_player.stream = sound
		audio_player.volume_db = volume_db
		audio_player.play()

func stop():
	audio_player.stop()
