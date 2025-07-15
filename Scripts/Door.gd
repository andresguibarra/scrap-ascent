@tool
extends Node2D

enum DoorState { OPEN, CLOSED, OPENING, CLOSING }
enum ActivationCondition { ALL, ANY }

@export var animation_duration: float = 1.0:
	set(value):
		animation_duration = max(0.1, value)  # Minimum 0.1 seconds
		_on_animation_duration_changed()
@export var progress_curve: Curve = null
@export var door_sound: AudioStream

static func _create_default_curve() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.0), 0.0, 2.0)
	curve.add_point(Vector2(1.0, 1.0), 2.0, 0.0)
	return curve
@export var start_open: bool = false
@export var trigger_nodes: Array[Node2D] = []
@export var activation_condition: ActivationCondition = ActivationCondition.ALL
@export var path_size_tiles: int = 1:
	set(value):
		path_size_tiles = max(1, value)
		_update_path_size()
@export var door_size_tiles: int = 1:
	set(value):
		door_size_tiles = max(1, value)
		_update_door_size()
@export var enable_left_marker: bool = true:
	set(value):
		enable_left_marker = value
		_update_marker_visibility()
@export var enable_right_marker: bool = true:
	set(value):
		enable_right_marker = value
		_update_marker_visibility()
@export var grow_width: bool = false:
	set(value):
		grow_width = value
		_update_door_size()
@export var left_marker_position: Vector2 = Vector2(-8, 16):
	set(value):
		left_marker_position = value
		_update_marker_positions()
@export var right_marker_position: Vector2 = Vector2(-8, -16):
	set(value):
		right_marker_position = value
		_update_marker_positions()
@export var use_custom_marker_positions: bool = false:
	set(value):
		use_custom_marker_positions = value
		_update_marker_positions()

@onready var path_follow: PathFollow2D = $MovementPath/PathFollow2D
@onready var crush_detector: Area2D = $MovementPath/PathFollow2D/DoorBody/CrushDetector
@onready var movement_path: Path2D = $MovementPath
@onready var door_body: AnimatableBody2D = $MovementPath/PathFollow2D/DoorBody
@onready var left_marker: Marker2D = $MovementPath/PathFollow2D/LeftMarker
@onready var right_marker: Marker2D = $MovementPath/PathFollow2D/RightMarker
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var current_state: DoorState = DoorState.CLOSED
var crushed_objects: Array[CharacterBody2D] = []

var animation_time: float = 0.0
var is_animating: bool = false
var target_progress: float = 0.0
var start_progress: float = 0.0
var audio_tween: Tween

func _ready() -> void:
	# Ensure each instance has its own unique curve
	if movement_path and movement_path.curve:
		movement_path.curve = movement_path.curve.duplicate()
	
	# Default curve if none is assigned
	if not progress_curve:
		progress_curve = _create_default_curve()
	
	if not Engine.is_editor_hint():
		_set_initial_state()
		_connect_to_trigger()
		_update_path_size()
		_update_door_size()
		_update_marker_visibility()
		_update_marker_positions()
	else:
		call_deferred("_update_path_size")
		call_deferred("_update_door_size")
		call_deferred("_update_marker_visibility")
		call_deferred("_update_marker_positions")

func _update_path_size():
	if not movement_path:
		return
	
	var curve = movement_path.curve
	if not curve:
		curve = Curve2D.new()
		movement_path.curve = curve
	
	# Clear existing points
	curve.clear_points()
	
	# Add start point (position out: y -path_size_tiles * 8)
	curve.add_point(Vector2(0, -path_size_tiles * 8))
	
	# Add end point (position in: y path_size_tiles * 8)
	curve.add_point(Vector2(0, path_size_tiles * 8))

func _process(delta: float) -> void:
	if not Engine.is_editor_hint() and is_animating:
		_update_animation(delta)
	if not Engine.is_editor_hint():
		if current_state == DoorState.CLOSING and path_follow:
		# Only crush when door is almost fully closed (10% progress, since 0.0 = closed)
			if path_follow.progress_ratio <= 0.1:
				_check_for_crushing()

#func _physics_process(_delta: float) -> void:
	#if current_state == DoorState.CLOSING and path_follow:
		## Only crush when door is almost fully closed (10% progress, since 0.0 = closed)
		#if path_follow.progress_ratio <= 0.1:
			#_check_for_crushing()

func _update_animation(delta: float) -> void:
	animation_time += delta
	var time_ratio = animation_time / animation_duration
	
	if time_ratio >= 1.0:
		# Animation complete
		time_ratio = 1.0
		is_animating = false
		_set_path_position(target_progress)
		_on_animation_complete()
	else:
		# Sample the curve and interpolate position
		var curve_value = progress_curve.sample(time_ratio)
		curve_value = clamp(curve_value, 0.0, 1.0)
		var current_progress = lerp(start_progress, target_progress, curve_value)
		_set_path_position(current_progress)

func _set_initial_state() -> void:
	if start_open:
		current_state = DoorState.OPEN
		_set_path_position(1.0)  # 1.0 = open
	else:
		current_state = DoorState.CLOSED
		_set_path_position(0.0)  # 0.0 = closed

func _connect_to_trigger() -> void:
	for trigger in trigger_nodes:
		if not trigger:
			continue
			
		if trigger.has_signal("activated"):
			if not trigger.activated.is_connected(_on_trigger_changed):
				trigger.activated.connect(_on_trigger_changed)
		
		if trigger.has_signal("deactivated"):
			if not trigger.deactivated.is_connected(_on_trigger_changed):
				trigger.deactivated.connect(_on_trigger_changed)

func _on_trigger_changed() -> void:
	var should_open := _evaluate_trigger_conditions()
	
	if should_open and (current_state == DoorState.CLOSED or current_state == DoorState.CLOSING):
		open_door()
	elif not should_open and (current_state == DoorState.OPEN or current_state == DoorState.OPENING):
		close_door()

func _evaluate_trigger_conditions() -> bool:
	if trigger_nodes.is_empty():
		return false
	
	match activation_condition:
		ActivationCondition.ALL:
			# All triggers must be activated
			for trigger in trigger_nodes:
				if not trigger or not trigger.has_method("get_is_active") or not trigger.get_is_active():
					return false
			return true
		
		ActivationCondition.ANY:
			# At least one trigger must be activated
			for trigger in trigger_nodes:
				if trigger and trigger.has_method("get_is_active") and trigger.get_is_active():
					return true
			return false
	
	return false

func _set_path_position(progress: float) -> void:
	if path_follow:
		path_follow.progress_ratio = progress

func open_door() -> void:
	if Engine.is_editor_hint():
		return
		
	if current_state == DoorState.OPEN or current_state == DoorState.OPENING:
		return
	
	current_state = DoorState.OPENING
	_play_door_sound()
	_start_animation(1.0)

func close_door() -> void:
	if Engine.is_editor_hint():
		return
		
	if current_state == DoorState.CLOSED or current_state == DoorState.CLOSING:
		return
	
	# Clear the crushed objects list when starting to close
	crushed_objects.clear()
	current_state = DoorState.CLOSING
	_play_door_sound()
	_start_animation(0.0)

func toggle_door() -> void:
	match current_state:
		DoorState.OPEN:
			close_door()
		DoorState.CLOSED:
			open_door()

func _start_animation(target: float) -> void:
	# Always start from current position and animate to target
	start_progress = path_follow.progress_ratio if path_follow else 0.0
	target_progress = target
	
	# Adjust duration based on distance to travel for smoother transitions
	var distance_to_travel = abs(target_progress - start_progress)
	if distance_to_travel < 0.01:
		# Already at target, no need to animate
		is_animating = false
		return
	
	# Reset animation time to start fresh
	animation_time = 0.0
	is_animating = true

func _on_animation_complete() -> void:
	_stop_door_sound()
	match current_state:
		DoorState.OPENING:
			current_state = DoorState.OPEN
		DoorState.CLOSING:
			current_state = DoorState.CLOSED

func is_open() -> bool:
	return current_state == DoorState.OPEN

func is_closed() -> bool:
	return current_state == DoorState.CLOSED

func is_moving() -> bool:
	return current_state == DoorState.OPENING or current_state == DoorState.CLOSING

func _check_for_crushing() -> void:
	if not crush_detector:
		return
	
	var overlapping_bodies = crush_detector.get_overlapping_bodies()
	for body in overlapping_bodies:
		# Handle enemies
		if body.is_in_group("enemies") and body not in crushed_objects:
			_crush_object(body)
			crushed_objects.append(body)
		# Handle orbs
		elif body.is_in_group("orbs") and body not in crushed_objects:
			_crush_object(body)
			crushed_objects.append(body)

func _crush_object(object: CharacterBody2D) -> void:
	## Apply damage/destruction based on object type
	#if object.is_in_group("enemies"):
		#object.destroy_chip()
	#elif object.is_in_group("orbs"):
		## Orbs don't have destroy_chip, but we still need to move them
		#pass
	
	# Move object to the closest marker
	_move_to_closest_marker(object)

func _move_to_closest_marker(object: CharacterBody2D) -> void:
	var available_markers: Array[Marker2D] = []
	
	# Collect enabled markers
	if left_marker and enable_left_marker:
		available_markers.append(left_marker)
	if right_marker and enable_right_marker:
		available_markers.append(right_marker)
	
	# If no markers are enabled, use fallback
	if available_markers.is_empty():
		print("Door: Warning - No markers enabled, using fallback positioning")
		_fallback_position_object(object)
		return
	
	# If only one marker is enabled, always use it regardless of position
	var target_marker: Marker2D
	if available_markers.size() == 1:
		target_marker = available_markers[0]
	else:
		# Multiple markers enabled, choose the closest one
		var distance_to_left = object.global_position.distance_to(left_marker.global_position)
		var distance_to_right = object.global_position.distance_to(right_marker.global_position)
		target_marker = left_marker if distance_to_left < distance_to_right else right_marker
	
	# Move object to the chosen marker position
	object.global_position = target_marker.global_position
	
	# Ensure object is aligned to tile grid (16px tiles)
	object.global_position.x = round(object.global_position.x / 16.0) * 16.0
	object.global_position.y = round(object.global_position.y / 16.0) * 16.0

func _fallback_position_object(object: CharacterBody2D) -> void:
	# Fallback method if markers are not available
	if not door_body:
		return
	
	# Calculate direction to move object
	var dir = sign(object.global_position.x - door_body.global_position.x)
	if dir == 0:
		dir = 1  # Default to right if centered
	
	# Move object completely out of door area
	var displacement = dir * 32  # 2 tiles away
	object.global_position.x += displacement
	
	# Ensure object is aligned to tile grid (16px tiles)
	object.global_position.x = round(object.global_position.x / 16.0) * 16.0
	object.global_position.y = round(object.global_position.y / 16.0) * 16.0

func _update_door_size():
	if not door_body:
		return
	
	if grow_width:
		# Grow the door width (X scale) instead of length
		door_body.scale.x = float(door_size_tiles)
		door_body.scale.y = 1.0
		
		# For width growth, keep the door at the original position
		# No compensation needed, just stay at the movement path position
		door_body.position.x = -8.0
		
		# Only adjust markers if not using custom positions
		if not use_custom_marker_positions:
			# Adjust markers for width growth - they move further apart
			var marker_offset: float = 8.0 * door_size_tiles
			if left_marker:
				left_marker.position.x = -marker_offset
			if right_marker:
				right_marker.position.x = -marker_offset
	else:
		# Original behavior: grow length (Y scale)
		door_body.scale.y = float(door_size_tiles)
		door_body.scale.x = 1.0
		
		# Compensate position: DoorBody is rotated -90 degrees, so Y scale affects X position
		# door_size_tiles = 1 => position.x = -8
		# door_size_tiles = 2 => position.x = -16  
		# door_size_tiles = 3 => position.x = -24
		door_body.position.x = -8.0 * door_size_tiles
		
		# Only adjust markers if not using custom positions
		if not use_custom_marker_positions:
			# Also adjust marker positions to match the scaled door
			# Since the door is rotated -90°, markers need to be positioned at the extremes
			# Formula: (-16 * tiles) + 8 ensures markers stay at door edges when scaled
			# door_size_tiles = 1 => markers at x = -8  (original position)
			# door_size_tiles = 2 => markers at x = -24 (extended door edges)  
			# door_size_tiles = 3 => markers at x = -40 (further extended edges)
			var marker_x_pos: float = (-16.0 * door_size_tiles) + 8.0
			if left_marker:
				left_marker.position.x = marker_x_pos
			if right_marker:
				right_marker.position.x = marker_x_pos

func _update_marker_visibility():
	if left_marker:
		left_marker.visible = enable_left_marker
	if right_marker:
		right_marker.visible = enable_right_marker

func _update_marker_positions():
	if use_custom_marker_positions:
		if left_marker:
			left_marker.position = left_marker_position
		if right_marker:
			right_marker.position = right_marker_position
	# If not using custom positions, _update_door_size() will handle positioning

# =============================================================================
# AUDIO SYSTEM
# Auto-adjusts to animation_duration changes for perfect synchronization
# =============================================================================
func _play_door_sound() -> void:
	if door_sound and audio_player:
		# Stop any previous audio tween and reset volume
		if audio_tween:
			audio_tween.kill()
		
		_reset_audio_volume()
		
		# Start playing the sound
		audio_player.stream = door_sound
		audio_player.play()
		
		# Create a tween that will stop the sound when animation finishes
		# This automatically uses the current animation_duration value
		_schedule_audio_stop()

func _schedule_audio_stop() -> void:
	if audio_tween:
		audio_tween.kill()
	
	# Always use the current animation_duration for precise timing
	audio_tween = create_tween()
	audio_tween.tween_callback(_stop_door_sound).set_delay(animation_duration)

func _on_animation_duration_changed() -> void:
	# If audio is currently playing and we have an active tween, reschedule it
	# This ensures audio always matches the current animation duration
	if audio_player and audio_player.playing and audio_tween and audio_tween.is_valid():
		_schedule_audio_stop()

func _stop_door_sound() -> void:
	if audio_player and audio_player.playing:
		# Create a quick fade out for smooth audio ending
		var fade_tween = create_tween()
		fade_tween.tween_property(audio_player, "volume_db", -80.0, 0.1)
		fade_tween.tween_callback(audio_player.stop)
		fade_tween.tween_callback(_reset_audio_volume)

func _reset_audio_volume() -> void:
	if audio_player:
		audio_player.volume_db = 0.0
