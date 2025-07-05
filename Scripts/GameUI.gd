extends Control

@export var hold_duration: float = 3.0

@onready var restart_label: Label = $RestartLabel

var is_holding_restart: bool = false
var hold_timer: float = 0.0

func _ready() -> void:
	# Set up the restart label
	_setup_restart_label()
	
	# Enable processing during pause for win condition
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	# Follow the camera position
	_update_position_to_camera()
	
	# Handle hold restart logic
	_handle_restart_input(delta)

func _setup_restart_label() -> void:
	if restart_label:
		restart_label.text = "Hold R to Restart"
		restart_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		restart_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

func _update_position_to_camera() -> void:
	var camera = get_viewport().get_camera_2d()
	if camera:
		var screen_size = get_viewport().get_visible_rect().size
		var zoom = camera.zoom
		
		# Calculate the visible area with zoom
		var visible_size = screen_size / zoom
		
		# Position the UI to follow the camera
		global_position = camera.global_position - visible_size * 0.5
		
		# Set the size to match the visible area
		size = visible_size

func _handle_restart_input(delta: float) -> void:
	# Check if game is paused (win condition) - then R works instantly
	if get_tree().paused:
		if Input.is_action_just_pressed("ui_select") or Input.is_key_pressed(KEY_R):
			_restart_game()
		return
	
	# Normal gameplay - hold R for 3 seconds
	var r_pressed = Input.is_key_pressed(KEY_R)
	
	if r_pressed:
		if not is_holding_restart:
			is_holding_restart = true
			hold_timer = 0.0
		
		hold_timer += delta
		
		# Update label with progress
		var progress = hold_timer / hold_duration
		if progress < 1.0:
			var progress_text = "Hold R to Restart (" + str(int((1.0 - progress) * hold_duration) + 1) + "s)"
			restart_label.text = progress_text
		else:
			# Time's up, restart the game
			_restart_game()
	else:
		# R key released, reset
		if is_holding_restart:
			is_holding_restart = false
			hold_timer = 0.0
			restart_label.text = "Hold R to Restart"

func _restart_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
