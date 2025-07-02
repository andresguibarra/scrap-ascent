extends Node2D

enum DoorState { OPEN, CLOSED, OPENING, CLOSING }

@export var movement_distance: float = 16.0
@export var animation_duration: float = 1.0
@export var start_open: bool = true
@export var trigger_node: Node2D

#@onready var movement_path: Path2D = $MovementPath
@onready var path_follow: PathFollow2D = $MovementPath/PathFollow2D
#@onready var collision_shape: CollisionShape2D = $MovementPath/PathFollow2D/DoorBody/CollisionShape2D

var current_state: DoorState = DoorState.OPEN
var tween: Tween

#func _process(delta: float) -> void:
	#collision_shape.global_position = collision_shape.global_position

func _ready() -> void:
	#_setup_movement_path()
	_set_initial_state()
	_connect_to_trigger()

#func _setup_movement_path() -> void:
	#if not movement_path or not path_follow:
		#return
	
	#var curve = Curve2D.new()
	#curve.add_point(Vector2.ZERO)
	#curve.add_point(Vector2(0, movement_distance))
	#movement_path.curve = curve

func _set_initial_state() -> void:
	if start_open:
		current_state = DoorState.OPEN
		_set_path_position(0.0)
	else:
		current_state = DoorState.CLOSED
		_set_path_position(1.0)

func _connect_to_trigger() -> void:
	if trigger_node and trigger_node.has_signal("activated"):
		if not trigger_node.activated.is_connected(_on_trigger_activated):
			trigger_node.activated.connect(_on_trigger_activated)
	
	if trigger_node and trigger_node.has_signal("deactivated"):
		if not trigger_node.deactivated.is_connected(_on_trigger_deactivated):
			trigger_node.deactivated.connect(_on_trigger_deactivated)

func _on_trigger_activated() -> void:
	activate()

func _on_trigger_deactivated() -> void:
	deactivate()

# Interface methods - these can be called by any trigger system
func activate() -> void:
	close_door()
	print("Door activated (closing)!")

func deactivate() -> void:
	open_door()
	print("Door deactivated (opening)!")

func _set_path_position(progress: float) -> void:
	if path_follow:
		path_follow.progress_ratio = progress

func open_door() -> void:
	if current_state == DoorState.OPEN or current_state == DoorState.OPENING:
		return
	
	current_state = DoorState.OPENING
	_animate_door(0.0, DoorState.OPEN)
	print("Door opening...")

func close_door() -> void:
	if current_state == DoorState.CLOSED or current_state == DoorState.CLOSING:
		return
	
	current_state = DoorState.CLOSING
	_animate_door(1.0, DoorState.CLOSED)
	print("Door closing...")

func toggle_door() -> void:
	match current_state:
		DoorState.OPEN:
			close_door()
		DoorState.CLOSED:
			open_door()
		_:
			pass  # Don't toggle while animating

func _animate_door(target_progress: float, final_state: DoorState) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	var current_progress = path_follow.progress_ratio if path_follow else 0.0
	tween.tween_method(_set_path_position, current_progress, target_progress, animation_duration)
	tween.tween_callback(_on_animation_complete.bind(final_state))

func _on_animation_complete(final_state: DoorState) -> void:
	current_state = final_state
	match final_state:
		DoorState.OPEN:
			print("Door opened!")
		DoorState.CLOSED:
			print("Door closed!")

func is_open() -> bool:
	return current_state == DoorState.OPEN

func is_closed() -> bool:
	return current_state == DoorState.CLOSED

func is_moving() -> bool:
	return current_state == DoorState.OPENING or current_state == DoorState.CLOSING
