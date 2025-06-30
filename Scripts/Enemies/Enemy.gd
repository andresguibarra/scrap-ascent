extends CharacterBody2D
class_name Enemy

enum State { AI, INERT, CONTROLLED }
enum Skill { MOVE, JUMP, DOUBLE_JUMP, DASH }

@export var skills: Array[Skill] = [Skill.MOVE, Skill.JUMP]
@export var jump_velocity: float = -600.0
@export var ai_speed: float = 100.0
@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.2

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_state: State = State.AI
var chip_destroyed: bool = false
var is_dashing: bool = false
var dash_timer: float = 0.0

# Jump and dash tracking
var jumps_remaining: int = 0
var max_jumps: int = 1
var can_dash_in_air: bool = true

@onready var edge_raycast: RayCast2D = $EdgeRayCast2D
@onready var wall_raycast: RayCast2D = $WallRayCast2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	name = "Enemy"
	add_to_group("enemies")
	_setup_jump_system()
	_update_visual_state()

func _setup_jump_system() -> void:
	# Set max jumps based on skills
	max_jumps = 1  # Default single jump
	if Skill.DOUBLE_JUMP in skills:
		max_jumps = 2
	jumps_remaining = max_jumps

func _process(delta: float) -> void:
	_update_timers(delta)
	_update_physics(delta)
	_handle_state_logic()
	move_and_slide()

func _update_timers(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false

func _update_physics(delta: float) -> void:
	# Reset abilities when touching ground
	if is_on_floor():
		jumps_remaining = max_jumps
		can_dash_in_air = true
	
	# Apply gravity (unless dashing)
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta

func _handle_state_logic() -> void:
	match current_state:
		State.AI:
			_handle_ai_patrol()
		State.INERT:
			_handle_inert_movement()
		State.CONTROLLED:
			_handle_player_input()

func posses():
	current_state = State.CONTROLLED
	_update_visual_state()

func is_controlled():
	return current_state == State.CONTROLLED

func _unhandled_input(_event: InputEvent) -> void:
	if is_controlled() and InputManager.is_possess_just_pressed():
		print("Enemy: releasing control")
		_release_control()
		get_viewport().set_input_as_handled()

func _handle_player_input() -> void:
	var direction: Vector2 = InputManager.get_movement_input()
	var jump: bool = InputManager.is_jump_just_pressed()
	var dash: bool = InputManager.is_dash_just_pressed()
	_apply_player_input(direction, jump, dash)

func _apply_player_input(direction: Vector2, jump: bool, dash: bool) -> void:
	# Handle dash first - can only dash once in air
	if _should_dash(dash, direction):
		return
	
	# Skip normal movement if dashing
	if is_dashing:
		return
	
	# Apply horizontal movement
	_apply_horizontal_movement(direction.x)
	
	# Apply jump - can jump multiple times if has double jump
	_apply_jump(jump)

func _should_dash(dash_input: bool, direction: Vector2) -> bool:
	if not dash_input or Skill.DASH not in skills or is_dashing:
		return false
		
	var can_dash := is_on_floor() or can_dash_in_air
	if not can_dash:
		return false
		
	var dash_direction: float = direction.x if direction.x != 0.0 else (1.0 if not sprite.flip_h else -1.0)
	_perform_dash(dash_direction)
	
	if not is_on_floor():
		can_dash_in_air = false
	return true

func _apply_horizontal_movement(direction_x: float) -> void:
	if direction_x != 0:
		velocity.x = direction_x * ai_speed * 2.0
		_flip_to_direction(direction_x)
	else:
		velocity.x = move_toward(velocity.x, 0, ai_speed * 2.0)

func _apply_jump(jump_input: bool) -> void:
	if jump_input and Skill.JUMP in skills and jumps_remaining > 0:
		velocity.y = jump_velocity
		jumps_remaining -= 1

func _perform_dash(direction: float) -> void:
	is_dashing = true
	dash_timer = dash_duration
	velocity.x = direction * dash_speed
	velocity.y = 0
	_flip_to_direction(direction)


func _flip_to_direction(dir: float) -> void:
	if dir > 0:
		sprite.flip_h = false  # Facing right
	elif dir < 0:
		sprite.flip_h = true   # Facing left

func _release_control() -> void:
	# Store current velocity to preserve momentum
	var current_velocity := velocity
	
	# Reset state based on chip status
	if chip_destroyed:
		current_state = State.INERT
	else:
		current_state = State.AI
	
	# Create new Orb at this position
	var orb_scene := preload("res://Scenes/Orb.tscn")
	var new_orb := orb_scene.instantiate()
	new_orb.name = "Orb"
	new_orb.global_position = global_position
	
	# Add to scene
	get_tree().current_scene.add_child(new_orb)
	
	# Preserve momentum when releasing control
	_preserve_momentum_after_release(current_velocity)
	
	# Update visual state
	_update_visual_state()

func _preserve_momentum_after_release(previous_velocity: Vector2) -> void:
	# Keep the velocity to maintain inertia
	velocity = previous_velocity
	
	# If we're in the air, reduce horizontal velocity slightly for natural feel
	if not is_on_floor():
		velocity.x *= 0.8  # Slight air resistance effect

func _handle_ai_patrol() -> void:
	var current_direction := get_facing_direction()
	
	if _should_turn_around(current_direction):
		_turn_around()
		current_direction *= -1
	
	velocity.x = current_direction * ai_speed

func _should_turn_around(direction: float) -> bool:
	return _has_edge_ahead(direction) or _has_wall_ahead(direction)

func _has_edge_ahead(direction: float) -> bool:
	if not edge_raycast:
		return false
		
	edge_raycast.target_position = Vector2(48 * direction, 32)
	edge_raycast.force_raycast_update()
	
	return is_on_floor() and not edge_raycast.is_colliding()

func _has_wall_ahead(direction: float) -> bool:
	if not wall_raycast:
		return false
		
	wall_raycast.target_position = Vector2(20 * direction, 0)
	wall_raycast.force_raycast_update()
	
	return wall_raycast.is_colliding()

func _turn_around() -> void:
	var current_direction := get_facing_direction()
	_flip_to_direction(-current_direction)

func _handle_inert_movement() -> void:
	velocity.x = move_toward(velocity.x, 0, ai_speed * 2.0)

func destroy_chip() -> void:
	chip_destroyed = true
	if current_state != State.CONTROLLED:
		current_state = State.INERT
		_update_visual_state()

func _update_visual_state() -> void:
	match current_state:
		State.AI:
			sprite.modulate = Color(0.8, 0.4, 0.4, 1.0)  # Red when AI
		State.INERT:
			sprite.modulate = Color(0.3, 0.3, 0.3, 1.0)  # Gray when inert
		State.CONTROLLED:
			sprite.modulate = Color(0.4, 0.8, 0.4, 1.0)  # Green when controlled

func get_facing_direction() -> float:
	return 1.0 if not sprite.flip_h else -1.0

func take_damage(_damage_amount: float) -> void:
	match current_state:
		State.CONTROLLED:
			_release_control()
		State.AI:
			destroy_chip()
		State.INERT:
			pass  # Already destroyed, no effect
