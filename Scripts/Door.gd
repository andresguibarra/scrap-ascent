@tool
extends Node2D

enum DoorState { OPEN, CLOSED, OPENING, CLOSING }

@export var animation_duration: float = 1.0
@export var start_open: bool = false
@export var trigger_node: Node2D
@export var path_size_tiles: int = 1:
	set(value):
		path_size_tiles = max(1, value)
		_update_path_size()

@onready var path_follow: PathFollow2D = $MovementPath/PathFollow2D
@onready var crush_detector: Area2D = $MovementPath/PathFollow2D/DoorBody/CrushDetector
@onready var movement_path: Path2D = $MovementPath

var current_state: DoorState = DoorState.CLOSED
var tween: Tween
var crushed_enemies: Array[CharacterBody2D] = []

func _ready() -> void:
	# Ensure each instance has its own unique curve
	if movement_path and movement_path.curve:
		movement_path.curve = movement_path.curve.duplicate()
	
	if not Engine.is_editor_hint():
		_set_initial_state()
		_connect_to_trigger()
		_update_path_size()
	else:
		call_deferred("_update_path_size")

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

func _physics_process(_delta: float) -> void:
	if current_state == DoorState.CLOSING and path_follow:
		# Only crush when door is almost fully closed (10% progress, since 0.0 = closed)
		if path_follow.progress_ratio <= 0.1:
			_check_for_crushing()

func _set_initial_state() -> void:
	if start_open:
		current_state = DoorState.OPEN
		_set_path_position(1.0)  # 1.0 = open
	else:
		current_state = DoorState.CLOSED
		_set_path_position(0.0)  # 0.0 = closed

func _connect_to_trigger() -> void:
	if trigger_node and trigger_node.has_signal("activated"):
		if not trigger_node.activated.is_connected(_on_trigger_activated):
			trigger_node.activated.connect(_on_trigger_activated)
	
	if trigger_node and trigger_node.has_signal("deactivated"):
		if not trigger_node.deactivated.is_connected(_on_trigger_deactivated):
			trigger_node.deactivated.connect(_on_trigger_deactivated)

func _on_trigger_activated() -> void:
	open_door()

func _on_trigger_deactivated() -> void:
	close_door()

func _set_path_position(progress: float) -> void:
	if path_follow:
		path_follow.progress_ratio = progress

func open_door() -> void:
	if Engine.is_editor_hint():
		return
		
	if current_state == DoorState.OPEN or current_state == DoorState.OPENING:
		return
	
	current_state = DoorState.OPENING
	_animate_door(1.0, DoorState.OPEN)  # 1.0 = open

func close_door() -> void:
	if Engine.is_editor_hint():
		return
		
	if current_state == DoorState.CLOSED or current_state == DoorState.CLOSING:
		return
	
	# Clear the crushed enemies list when starting to close
	crushed_enemies.clear()
	current_state = DoorState.CLOSING
	_animate_door(0.0, DoorState.CLOSED)  # 0.0 = closed

func toggle_door() -> void:
	match current_state:
		DoorState.OPEN:
			close_door()
		DoorState.CLOSED:
			open_door()

func _animate_door(target_progress: float, final_state: DoorState) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	var current_progress = path_follow.progress_ratio if path_follow else 0.0
	tween.tween_method(_set_path_position, current_progress, target_progress, animation_duration)
	tween.tween_callback(_on_animation_complete.bind(final_state))

func _on_animation_complete(final_state: DoorState) -> void:
	current_state = final_state

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
		if body.is_in_group("enemies") and not body.chip_destroyed and body not in crushed_enemies:
			_crush_enemy(body)
			crushed_enemies.append(body)

func _crush_enemy(enemy: CharacterBody2D) -> void:
	enemy.destroy_chip()
	
	var door_body = path_follow.get_child(0) as AnimatableBody2D
	if not door_body:
		return
	
	# Calculate direction to move enemy
	var dir = sign(enemy.global_position.x - door_body.global_position.x)
	if dir == 0:
		dir = 1  # Default to right if centered
	
	# Move enemy completely out of door area (2 tiles = 32 pixels to ensure clearance)
	var displacement = dir * 17
	enemy.global_position.x += displacement
	
	# Ensure enemy is aligned to tile grid (16px tiles)
	enemy.global_position.x = round(enemy.global_position.x / 16.0) * 16.0
	enemy.global_position.y = round(enemy.global_position.y / 16.0) * 16.0
