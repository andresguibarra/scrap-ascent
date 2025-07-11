@tool
extends CharacterBody2D
class_name Enemy

enum State { AI, INERT, CONTROLLED }
enum Skill { MOVE, JUMP, DOUBLE_JUMP, DASH, WALL_CLIMB }

var skills = {
	1: [Skill.MOVE, Skill.JUMP],
	2: [Skill.MOVE, Skill.JUMP, Skill.DASH],
	3: [Skill.MOVE, Skill.JUMP, Skill.DASH, Skill.WALL_CLIMB],
	4: [Skill.MOVE, Skill.JUMP, Skill.DOUBLE_JUMP, Skill.DASH, Skill.WALL_CLIMB],
}

# Export properties
@export var current_state: Enemy.State = Enemy.State.AI:
	set(new_state):
		# Update previous_main_state only if changing from a non-controlled state
		if current_state != Enemy.State.CONTROLLED and new_state != current_state:
			if new_state == Enemy.State.CONTROLLED:
				# About to be controlled, save current state
				previous_main_state = current_state
		
		current_state = new_state
		if current_state == Enemy.State.INERT:
			chip_destroyed = true
		if Engine.is_editor_hint() and is_inside_tree():
			_update_visual_state()

@export var tier = 1:
	set(new_tier):
		tier = new_tier
		if Engine.is_editor_hint():
			_update_editor_visuals()

@export var has_weapon = false:
	set(new_has_weapon):
		has_weapon = new_has_weapon
		if Engine.is_editor_hint():
			_update_editor_visuals()

@export var face_right = false:
	set(new_face_right):
		face_right = !!new_face_right
		if Engine.is_editor_hint():
			_update_editor_visuals()

# Physics and movement parameters
@export var jump_velocity: float = -360.0
@export var ai_speed: float = 100.0
@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.13 
@export var coyote_time: float = 0.1
@export var wall_slide_speed: float = 50.0
@export var wall_jump_cooldown_time: float = 0.8

# Tier colors
@export var tier_1_color: Color = Color(0.8, 0.4, 0.4, 1.0)
@export var tier_2_color: Color = Color(0.4, 0.6, 0.9, 1.0)
@export var tier_3_color: Color = Color(0.9, 0.6, 0.2, 1.0)
@export var tier_4_color: Color = Color(0.7, 0.3, 0.8, 1.0)
@export var inert_color: Color = Color(0.3, 0.3, 0.3, 1.0)

# Audio
@export var jump_sound: AudioStream
@export var double_jump_sound: AudioStream
@export var dash_sound: AudioStream
@export var release_sound: AudioStream
@export var destroy_sound: AudioStream
@export var wall_slide_sound: AudioStream

# Physics constants
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Essential state variables
var chip_destroyed: bool = false
var weapon_instance: Weapon = null
var previous_main_state: Enemy.State = Enemy.State.AI  # Para recordar el estado antes del control
var has_used_double_jump: bool = false  # Para rastrear si ya usó double jump en el aire actual
var has_used_dash: bool = false  # Para rastrear si ya usó double jump en el aire actual

# Wall jump cooldown tracking
var wall_jump_cooldown: float = 0.0
var last_wall_jump_normal: Vector2 = Vector2.ZERO

# Jump buffer for coyote-like behavior
var jump_buffer_timer: float = 0.0
var jump_buffer_time: float = 0.3  # Reduced from 0.3 to 0.15 for better balance

# Node references
@onready var edge_raycast: RayCast2D = $EdgeRayCast2D
@onready var wall_raycast: RayCast2D = $WallRayCast2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var eyes_sprite: AnimatedSprite2D = $Eyes
@onready var light: PointLight2D = $PointLight2D
@onready var damage_particles: GPUParticles2D = $DamageParticles
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var state_machine: Node = $StateMachine

func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("_update_editor_visuals")
		return
		
	# Runtime initialization
	name = "Enemy"
	add_to_group("enemies")
	
	# Initialize previous_main_state correctly
	if chip_destroyed:
		previous_main_state = Enemy.State.INERT
	else:
		previous_main_state = Enemy.State.AI
	
	_setup_tier_configuration()
	_setup_weapon_if_needed()
	_update_visual_state()
	call_deferred("_initialize_eyes_state")
	call_deferred("_connect_state_machine_signals")

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	# Update wall jump cooldown timer
	if wall_jump_cooldown > 0.0:
		wall_jump_cooldown -= delta
	# Update jump buffer timer
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta
	# Reset wall jump cooldown when touching ground
	if is_on_floor():
		wall_jump_cooldown = 0.0

# CONFIGURATION METHODS
func _setup_tier_configuration() -> void:
	if tier in skills:
		match tier:
			1: ai_speed = 80.0
			2: ai_speed = 100.0
			3: ai_speed = 120.0
			4: ai_speed = 140.0

func _setup_weapon_if_needed() -> void:
	if has_weapon and not weapon_instance:
		_instantiate_weapon()

func _instantiate_weapon() -> void:
	var weapon_scene := preload("res://Scenes/Weapon.tscn")
	weapon_instance = weapon_scene.instantiate()
	add_child(weapon_instance)

func _initialize_eyes_state() -> void:
	if eyes_sprite:
		eyes_sprite.visible = (current_state == Enemy.State.CONTROLLED)

# STATE MACHINE INTEGRATION
func _connect_state_machine_signals() -> void:
	if not state_machine:
		print("Enemy: StateMachine not found!")
		return
		
	if not state_machine.has_signal("state_changed"):
		print("Enemy: StateMachine does not have state_changed signal!")
		return
		
	if not state_machine.state_changed.is_connected(_on_state_changed):
		state_machine.state_changed.connect(_on_state_changed)

func _on_state_changed() -> void:
	if not state_machine or not state_machine.state:
		return
		
	var state_name = state_machine.state.name
	var new_state: Enemy.State
	
	if state_name.begins_with("AI"):
		new_state = Enemy.State.AI
	elif state_name.begins_with("Controlled"):
		new_state = Enemy.State.CONTROLLED
	elif state_name.begins_with("Inert"):
		new_state = Enemy.State.INERT
	else:
		return
	
	if new_state != current_state:
		current_state = new_state
		if is_inside_tree():
			_update_visual_state()

# PUBLIC METHODS FOR STATES
func get_tier_color() -> Color:
	match current_state:
		Enemy.State.INERT:
			return inert_color
		_:
			match tier:
				1: return tier_1_color
				2: return tier_2_color
				3: return tier_3_color
				_: return tier_4_color

func has_skill(skill: Skill) -> bool:
	return skill in skills.get(tier, [])

func play_sound(sound: AudioStream) -> void:
	if sound and audio_player:
		audio_player.stream = sound
		audio_player.play()

func spawn_damage_particles() -> void:
	if damage_particles:
		damage_particles.restart()

func is_controlled() -> bool:
	return current_state == Enemy.State.CONTROLLED

func get_facing_direction() -> float:
	return 1.0 if face_right else -1.0

func reset_air_abilities() -> void:
	has_used_double_jump = false
	has_used_dash = false

func can_double_jump() -> bool:
	return has_skill(Skill.DOUBLE_JUMP) and not has_used_double_jump

func can_dash() -> bool:
	return has_skill(Skill.DASH) and not has_used_dash
	
func use_dash() -> void:
	has_used_dash = true
	
func use_double_jump() -> void:
	has_used_double_jump = true

func can_wall_jump() -> bool:
	if not has_skill(Skill.WALL_CLIMB):
		return false
	
	# Check if we're in cooldown for the current wall
	if is_against_wall():
		var current_wall_normal = get_current_wall_normal()
		var is_same_wall = is_same_wall_as_last_jump(current_wall_normal)
		
		# STRICT LOGIC: Only allow wall jump if:
		# 1. It's a different wall, OR
		# 2. We never wall jumped before (first time)
		# NO retry on same wall after cooldown - prevents climbing
		var can_jump = not is_same_wall or last_wall_jump_normal == Vector2.ZERO
		
		return can_jump
	
	return true

func set_wall_jump_cooldown() -> void:
	wall_jump_cooldown = wall_jump_cooldown_time
	last_wall_jump_normal = get_current_wall_normal()

func reset_wall_jump_cooldown() -> void:
	wall_jump_cooldown = 0.0
	last_wall_jump_normal = Vector2.ZERO  # Reset the last wall reference too

func get_current_wall_normal() -> Vector2:
	if not wall_raycast:
		return Vector2.ZERO
	
	var direction = 1.0 if face_right else -1.0
	wall_raycast.target_position = Vector2(20 * direction, 0)
	wall_raycast.force_raycast_update()
	
	if wall_raycast.is_colliding():
		var normal = wall_raycast.get_collision_normal()
		return normal
	
	return Vector2.ZERO

func is_same_wall_as_last_jump(wall_normal_to_check: Vector2) -> bool:
	# If we don't have a valid last wall normal, it's a different wall
	if last_wall_jump_normal == Vector2.ZERO:
		return false
	
	# If current wall normal is invalid, assume different wall
	if wall_normal_to_check == Vector2.ZERO:
		return false
	
	var dot_product = wall_normal_to_check.dot(last_wall_jump_normal)
	var same_wall = dot_product > 0.9
	return same_wall

# PUBLIC METHODS FOR STATES (called by FSM states)
func apply_movement_and_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

# TRANSITION METHODS
func possess() -> void:
	# Save the current state before possessing (only if not already controlled)
	if current_state != Enemy.State.CONTROLLED:
		previous_main_state = current_state
	
	if state_machine and state_machine.has_method("transition_to"):
		if is_on_floor():
			state_machine.transition_to(EnemyState.CONTROLLED_IDLE)
		else:
			state_machine.transition_to(EnemyState.CONTROLLED_FALL)

func release_control() -> void:
	create_release_orb()
	
	if state_machine and state_machine.has_method("transition_to"):
		# Return to the state it was in before being controlled
		var target_state = previous_main_state
		
		# If chip was destroyed while controlled, force to INERT
		if chip_destroyed:
			target_state = Enemy.State.INERT
		
		print("Enemy releasing control: returning to ", target_state)
		
		match target_state:
			Enemy.State.AI:
				if is_on_floor():
					# Go to move state by default for AI behavior
					state_machine.transition_to(EnemyState.AI_MOVE)
				else:
					state_machine.transition_to(EnemyState.AI_FALL)
			Enemy.State.INERT:
				if is_on_floor():
					state_machine.transition_to(EnemyState.INERT_IDLE)
				else:
					state_machine.transition_to(EnemyState.INERT_FALL)

func destroy_chip() -> void:
	chip_destroyed = true
	spawn_damage_particles()
	play_sound(destroy_sound)
	if state_machine and state_machine.has_method("transition_to"):
		if is_on_floor():
			state_machine.transition_to(EnemyState.INERT_IDLE)
		else:
			state_machine.transition_to(EnemyState.INERT_FALL)

# DAMAGE SYSTEM
func take_damage() -> void:
	# # Only take damage if not controlled (to prevent self-damage)
	if current_state == Enemy.State.CONTROLLED:
		release_control()
		return
	# Spawn damage particles
	spawn_damage_particles()
	
	# Destroy the chip when taking damage
	destroy_chip()

# VISUAL METHODS
func _update_visual_state() -> void:
	if not animated_sprite:
		return
		
	animated_sprite.modulate = get_tier_color()
	
	if light:
		light.enabled = (current_state == Enemy.State.CONTROLLED)
	
	if eyes_sprite:
		eyes_sprite.visible = (current_state == Enemy.State.CONTROLLED)
		
# VISUAL METHODS  
func update_sprite_flip() -> void:
	if not animated_sprite:
		return
		
	if velocity.x > 0:
		animated_sprite.flip_h = true
		face_right = true
	elif velocity.x < 0:
		animated_sprite.flip_h = false
		face_right = false
	
	# Update eyes sprite to match
	if eyes_sprite and eyes_sprite.visible:
		eyes_sprite.flip_h = animated_sprite.flip_h

func set_animation(animation_name: String) -> void:
	if not animated_sprite or not animated_sprite.sprite_frames:
		return
		
	if animated_sprite.sprite_frames.has_animation(animation_name):
		if animated_sprite.animation != animation_name:
			animated_sprite.animation = animation_name
			animated_sprite.play()
			_update_eyes_animation(animation_name)

func _update_eyes_animation(body_animation: String) -> void:
	if not eyes_sprite or not eyes_sprite.visible:
		return
		
	if eyes_sprite.sprite_frames and eyes_sprite.sprite_frames.has_animation(body_animation):
		if eyes_sprite.animation != body_animation:
			eyes_sprite.animation = body_animation
			eyes_sprite.play()
		# Sync flip state
		if animated_sprite:
			eyes_sprite.flip_h = animated_sprite.flip_h

# EDITOR METHODS
func _update_editor_visuals() -> void:
	if not Engine.is_editor_hint():
		return
		
	if not animated_sprite:
		animated_sprite = get_node_or_null("AnimatedSprite2D")
	
	if animated_sprite:
		animated_sprite.modulate = get_tier_color()
		animated_sprite.flip_h = face_right
		
		if animated_sprite.sprite_frames:
			if animated_sprite.sprite_frames.has_animation("MoveLeft"):
				animated_sprite.animation = "MoveLeft"
				animated_sprite.frame = 0
			elif animated_sprite.sprite_frames.has_animation("Idle"):
				animated_sprite.animation = "Idle"
				animated_sprite.frame = 0
	
	_update_weapon_in_editor()

func _update_weapon_in_editor() -> void:
	if not Engine.is_editor_hint():
		return
		
	var existing_weapon = null
	for child in get_children():
		if child is Weapon:
			existing_weapon = child
			break
	
	if has_weapon and not existing_weapon:
		_instantiate_weapon()
	elif not has_weapon and existing_weapon:
		existing_weapon.queue_free()

func is_against_wall() -> bool:
	if not wall_raycast:
		return false
		
	var direction = 1.0 if face_right else -1.0
	wall_raycast.target_position = Vector2(20 * direction, 0)
	wall_raycast.force_raycast_update()
	return wall_raycast.is_colliding()

func is_at_edge() -> bool:
	if not edge_raycast:
		return false
		
	var direction = 1.0 if face_right else -1.0
	edge_raycast.target_position = Vector2(15 * direction, 15)
	edge_raycast.force_raycast_update()
	return not edge_raycast.is_colliding()

func create_release_orb() -> void:
	play_sound(release_sound)
	
	var orb_scene := preload("res://Scenes/Orb.tscn")
	var new_orb := orb_scene.instantiate()
	new_orb.name = "Orb"
	new_orb.global_position = global_position
	
	get_tree().current_scene.add_child(new_orb)

func set_jump_buffer() -> void:
	jump_buffer_timer = jump_buffer_time

func has_jump_buffer() -> bool:
	return jump_buffer_timer > 0.0

func consume_jump_buffer() -> void:
	jump_buffer_timer = 0.0
