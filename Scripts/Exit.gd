extends Area2D

@export var light_energy: float = 1.5
@export var light_color: Color = Color(0.9, 0.9, 0.6, 1.0)  # Warm white
@export var fade_duration: float = 2.0
@export var win_sound: AudioStream
@export var win_volume_db: float = 0.0

@onready var light: PointLight2D = $PointLight2D
@onready var win_ui: Control = $WinUI
@onready var win_label: Label = $WinUI/WinLabel
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var has_triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_setup_light()
	_setup_win_ui()
	_setup_audio()

func _setup_light() -> void:
	if light:
		light.enabled = true
		light.energy = light_energy
		light.color = light_color
		# Make light shine downward
		light.texture_scale = 2.0

func _setup_win_ui() -> void:
	if win_ui and win_label:
		# Initially hide the UI
		win_ui.visible = false
		win_label.modulate.a = 0.0
		
		# Set up the label text and styling
		win_label.text = "You found the exit!"
		win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		win_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		# Position UI centered on camera, not on the Exit area
		var camera = get_viewport().get_camera_2d()
		if camera:
			var screen_size = get_viewport().get_visible_rect().size
			win_ui.size = screen_size
			# Center the UI on the camera's global position
			win_ui.global_position = camera.global_position - screen_size * 0.5
		else:
			# Fallback if no camera found
			var screen_size = get_viewport().get_visible_rect().size
			win_ui.size = screen_size
			win_ui.position = Vector2.ZERO

func _setup_audio() -> void:
	if audio_player:
		# Configure audio to work during pause and with maximum reach
		audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
		audio_player.max_distance = 2000.0
		audio_player.volume_db = win_volume_db
		if win_sound:
			audio_player.stream = win_sound

func _on_body_entered(body: Node2D) -> void:
	if has_triggered:
		return
	
	# Check if it's a controlled enemy (player) or orb
	if body.is_in_group("enemies") and body.has_method("is_controlled") and body.is_controlled():
		_trigger_win()
	elif body.is_in_group("orbs"):
		_trigger_win()

func _trigger_win() -> void:
	if has_triggered:
		return
		
	has_triggered = true
	print("Exit: Player reached the exit - You Win!")
	
	# Play win sound FIRST before other operations
	_play_win_sound()
	
	# Small delay to ensure sound starts playing
	await get_tree().create_timer(0.1).timeout
	
	# Fade out background music
	if BackgroundMusic:
		BackgroundMusic.fade_out(fade_duration)
	
	# Pause the game
	get_tree().paused = true
	
	# Show and fade in the win message
	_show_win_message()

func _play_win_sound() -> void:
	if audio_player and win_sound:
		# Ensure audio continues during pause
		audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
		audio_player.stream = win_sound
		audio_player.volume_db = win_volume_db
		# Set to maximum distance to ensure it's heard
		audio_player.max_distance = 2000.0
		audio_player.play()
		print("Exit: Playing win sound")
	else:
		print("Exit: No win sound or audio player configured")

func _show_win_message() -> void:
	if not win_ui or not win_label:
		print("Exit: Warning - Win UI components not found!")
		return
	
	# Update UI position to current camera position before showing
	var camera = get_viewport().get_camera_2d()
	if camera:
		var screen_size = get_viewport().get_visible_rect().size
		win_ui.global_position = camera.global_position - screen_size * 0.5
	
	win_ui.visible = true
	win_ui.process_mode = Node.PROCESS_MODE_ALWAYS  # Allow processing during pause
	
	# Create fade in tween
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Continue during pause
	tween.tween_property(win_label, "modulate:a", 1.0, fade_duration)
	tween.tween_callback(_on_fade_complete)

func _on_fade_complete() -> void:
	print("Exit: Win message fade complete")
	# Optionally add input handling to restart or quit
	_setup_restart_input()

func _setup_restart_input() -> void:
	# Enable input processing during pause
	set_process_unhandled_input(true)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if has_triggered and event.is_action_pressed("ui_accept"):
		# Restart the game
		get_tree().paused = false
		# Force restart background music before reloading scene
		if BackgroundMusic:
			BackgroundMusic.restore_background_music()
		get_tree().reload_current_scene()
	elif has_triggered and event.is_action_pressed("ui_cancel"):
		# Quit the game
		get_tree().quit()
