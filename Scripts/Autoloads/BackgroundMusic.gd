extends AudioStreamPlayer

# Global background music manager
@export var background_music: AudioStream

# Available background music tracks
var music_tracks: Array[AudioStream] = []
var current_track: AudioStream

func _ready() -> void:
	# Configure as background music
	volume_db = -10.0  # Background volume
	autoplay = false
	bus = "Master"
	
	# Load available music tracks
	_load_music_tracks()
	
	# Select and play random background music
	_play_random_background_music()

func _load_music_tracks() -> void:
	# Load available background music tracks
	music_tracks.clear()
	
	var track1 = preload("res://Assets/Sounds/03 ship interior.ogg")
	var track2 = preload("res://Assets/Sounds/04 underground cavern.ogg")
	var track3 = preload("res://Assets/Sounds/05 gaseous tethanus.ogg")
	
	music_tracks.append(track1)
	music_tracks.append(track2)
	music_tracks.append(track3)
	
	print("BackgroundMusic: Loaded ", music_tracks.size(), " music tracks")

func _play_random_background_music() -> void:
	if music_tracks.is_empty():
		print("BackgroundMusic: No music tracks available")
		return
	
	# Select random track
	var random_index = randi() % music_tracks.size()
	current_track = music_tracks[random_index]
	
	# Play the selected track
	stream = current_track
	# Enable loop for background music
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	play()
	
	print("BackgroundMusic: Playing random track ", random_index + 1, "/", music_tracks.size())

func play_background_music(music: AudioStream = null) -> void:
	if music:
		# Play specific music if provided
		current_track = music
		stream = music
		# Enable loop for background music
		if stream is AudioStreamOggVorbis:
			stream.loop = true
		elif stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		play()
		print("BackgroundMusic: Playing specific background music")
	else:
		# Play random music if no specific music provided
		_play_random_background_music()

func stop_background_music() -> void:
	stop()
	print("BackgroundMusic: Stopped background music")

func set_background_volume(new_volume_db: float) -> void:
	volume_db = new_volume_db
	print("BackgroundMusic: Volume set to ", new_volume_db, " dB")

func fade_out(duration: float = 2.0) -> void:
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80.0, duration)
	tween.tween_callback(stop)

func fade_in(duration: float = 2.0) -> void:
	var original_volume = volume_db
	volume_db = -80.0
	play()
	var tween = create_tween()
	tween.tween_property(self, "volume_db", original_volume, duration)

func play_victory_sound(victory_music: AudioStream) -> void:
	if victory_music:
		# Stop current background music and play victory sound
		stop()
		stream = victory_music
		volume_db = 0.0  # Victory sound at full volume
		play()
		print("BackgroundMusic: Playing victory sound")

func restore_background_music() -> void:
	# Select and play a new random track when restoring
	_play_random_background_music()
	print("BackgroundMusic: Restored background music with new random selection")
