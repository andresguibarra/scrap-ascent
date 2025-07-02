extends CharacterBody2D
class_name Enemy

enum State { AI, INERT, CONTROLLED }
enum Skill { MOVE, JUMP, DOUBLE_JUMP, DASH, WALL_CLIMB }
var skills = {
	1: [Skill.MOVE, Skill.JUMP],
	2: [Skill.MOVE, Skill.JUMP, Skill.DASH, Skill.WALL_CLIMB],
	3: [Skill.MOVE, Skill.JUMP, Skill.DOUBLE_JUMP, Skill.DASH, Skill.WALL_CLIMB],
}
@export var tier = 1
@export var has_weapon = false
@export var jump_velocity: float = -360.0
@export var ai_speed: float = 100.0
@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.13
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.01
@export var flip_cooldown_time: float = 0.5  # Time to wait before allowing another flip
@export var wall_slide_speed: float = 50.0  # Speed when sliding down a wall
@export var wall_jump_velocity: Vector2 = Vector2(250.0, -300.0)  # Horizontal and vertical push from wall
@export var wall_jump_cooldown_time: float = 0.6  # Time before can grab same wall again

# Tier colors for AI state
@export var tier_1_color: Color = Color(0.8, 0.4, 0.4, 1.0)  # Red
@export var tier_2_color: Color = Color(0.4, 0.6, 0.9, 1.0)  # Blue
@export var tier_3_color: Color = Color(0.9, 0.6, 0.2, 1.0)  # Orange
@export var tier_4_color: Color = Color(0.7, 0.3, 0.8, 1.0)  # Purple

# State colors
@export var inert_color: Color = Color(0.3, 0.3, 0.3, 1.0)      # Gray
@export var controlled_color: Color = Color(0.4, 0.8, 0.4, 1.0)  # Green

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_state: State = State.AI
var chip_destroyed: bool = false
var is_dashing: bool = false
var dash_timer: float = 0.0

# Wall climbing state
var is_wall_sliding: bool = false
var wall_normal: Vector2 = Vector2.ZERO
var wall_jump_cooldown_timer: float = 0.0
var last_wall_normal: Vector2 = Vector2.ZERO  # Track which wall we last jumped from

# Jump and dash tracking
var jumps_remaining: int = 0
var max_jumps: int = 1
var can_dash_in_air: bool = true

# Coyote time and jump buffering
var coyote_timer: float = 0.0
var was_on_floor: bool = false
var jump_buffer_timer: float = 0.0

# Weapon reference (instantiated if has_weapon = true)
var weapon_instance: Weapon = null

# Flip cooldown tracking
var flip_cooldown_timer: float = 0.0
var last_flip_direction: float = 0.0

@onready var edge_raycast: RayCast2D = $EdgeRayCast2D
@onready var wall_raycast: RayCast2D = $WallRayCast2D
@onready var wall_left_raycast: RayCast2D = $WallLeftRayCast2D
@onready var wall_right_raycast: RayCast2D = $WallRightRayCast2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var eyes_sprite: AnimatedSprite2D = $Eyes
@onready var light: PointLight2D = $PointLight2D
@onready var damage_particles: GPUParticles2D = $DamageParticles

func _ready() -> void:
	name = "Enemy"
	add_to_group("enemies")
	_setup_tier_configuration()
	_setup_jump_system()
	_setup_weapon_if_needed()
	_update_visual_state()
	# Ensure animation starts correctly
	call_deferred("_update_animation")
	# Initialize eyes visibility based on initial state
	call_deferred("_initialize_eyes_state")
	# Debug print
	_print_configuration_debug()

func _initialize_eyes_state() -> void:
	if eyes_sprite:
		# Eyes start hidden unless in CONTROLLED state
		eyes_sprite.visible = (current_state == State.CONTROLLED)
		print("Enemy: Eyes initialized - visible: ", eyes_sprite.visible, " state: ", current_state)

func _setup_tier_configuration() -> void:
	# Configure skills based on tier
	if tier in skills:
		# Update AI speed based on tier
		match tier:
			1:
				ai_speed = 80.0
			2:
				ai_speed = 100.0
			3:
				ai_speed = 120.0
			4:
				ai_speed = 140.0

func _setup_jump_system() -> void:
	# Set max jumps based on tier skills
	var tier_skills = skills.get(tier, [Skill.MOVE, Skill.JUMP])
	max_jumps = 1  # Default single jump
	if Skill.DOUBLE_JUMP in tier_skills:
		max_jumps = 2
	jumps_remaining = max_jumps

func _setup_weapon_if_needed() -> void:
	if has_weapon and not weapon_instance:
		_instantiate_weapon()

func _instantiate_weapon() -> void:
	var weapon_scene := preload("res://Scenes/Weapon.tscn")
	weapon_instance = weapon_scene.instantiate()
	add_child(weapon_instance)
	print("Enemy: Weapon instantiated for tier ", tier)

func _print_configuration_debug() -> void:
	var tier_skills = skills.get(tier, [])
	var tier_color_name = ""
	match tier:
		1: tier_color_name = "Red"
		2: tier_color_name = "Blue" 
		3: tier_color_name = "Orange"
		_: tier_color_name = "Purple"
	
	var skill_names = []
	for skill in tier_skills:
		match skill:
			Skill.MOVE: skill_names.append("MOVE")
			Skill.JUMP: skill_names.append("JUMP")
			Skill.DOUBLE_JUMP: skill_names.append("DOUBLE_JUMP")
			Skill.DASH: skill_names.append("DASH")
			Skill.WALL_CLIMB: skill_names.append("WALL_CLIMB")
	
	print("Enemy configured - Tier: ", tier, " (", tier_color_name, "), Has Weapon: ", has_weapon, ", Skills: ", skill_names)

func _process(delta: float) -> void:
	_update_timers(delta)
	_update_physics(delta)
	_handle_state_logic()
	_update_animation()
	move_and_slide()

func _update_timers(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	
	# Update coyote timer
	if coyote_timer > 0.0:
		coyote_timer -= delta
	
	# Update jump buffer timer
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta
	
	# Update flip cooldown timer
	if flip_cooldown_timer > 0.0:
		flip_cooldown_timer -= delta
	
	# Update wall jump cooldown timer
	if wall_jump_cooldown_timer > 0.0:
		wall_jump_cooldown_timer -= delta

func _update_physics(delta: float) -> void:
	var currently_on_floor = is_on_floor()
	
	# Handle coyote time - start timer when leaving ground
	if was_on_floor and not currently_on_floor:
		coyote_timer = coyote_time
		# When leaving the ground, consume the first jump if we didn't jump
		if jumps_remaining == max_jumps:
			jumps_remaining -= 1
	
	# Reset abilities when touching ground
	if currently_on_floor:
		jumps_remaining = max_jumps
		can_dash_in_air = true
		coyote_timer = 0.0
		is_wall_sliding = false  # Stop wall sliding when on floor
		wall_jump_cooldown_timer = 0.0  # Reset wall jump cooldown when on ground
		last_wall_normal = Vector2.ZERO  # Clear wall memory when on ground
		
		# Execute buffered jump if there's one
		if jump_buffer_timer > 0.0:
			_execute_jump()
			jump_buffer_timer = 0.0
	
	# Update was_on_floor for next frame
	was_on_floor = currently_on_floor
	
	# Check for wall sliding if not on floor and not dashing
	if not currently_on_floor and not is_dashing:
		_update_wall_sliding()
	
	# Apply gravity (unless dashing or wall sliding)
	if not currently_on_floor and not is_dashing:
		if is_wall_sliding:
			# Slow fall when wall sliding
			velocity.y += wall_slide_speed * delta
		else:
			velocity.y += gravity * delta

func _update_wall_sliding() -> void:
	var tier_skills = skills.get(tier, [Skill.MOVE, Skill.JUMP])
	if Skill.WALL_CLIMB not in tier_skills:
		is_wall_sliding = false
		return
	
	# Wall climbing is only available when controlled by player
	if current_state != State.CONTROLLED:
		is_wall_sliding = false
		return
	
	# Check if we're touching a wall and falling
	var wall_data = _get_wall_collision()
	if wall_data.is_touching and velocity.y > 0:
		# Check if we changed wall direction (left to right or right to left)
		var has_changed_direction = _has_wall_direction_changed(wall_data.normal, last_wall_normal)
		
		# Reset cooldown if we changed wall direction
		if has_changed_direction:
			wall_jump_cooldown_timer = 0.0
		
		# Check if we're in wall jump cooldown for this specific wall
		var is_same_wall = _is_same_wall(wall_data.normal, last_wall_normal)
		if is_same_wall and wall_jump_cooldown_timer > 0.0:
			is_wall_sliding = false
			return
		
		# Only wall slide if actively moving towards the wall
		var direction = InputManager.get_movement_input()
		var moving_towards_wall = (wall_data.normal.x > 0 and direction.x < 0) or (wall_data.normal.x < 0 and direction.x > 0)
		
		if moving_towards_wall:
			# Check if we're transitioning from not wall sliding to wall sliding
			var was_wall_sliding = is_wall_sliding
			is_wall_sliding = true
			wall_normal = wall_data.normal
			
			# Execute buffered jump if there's one and we just started wall sliding
			if not was_wall_sliding and jump_buffer_timer > 0.0 and Skill.WALL_CLIMB in tier_skills:
				_execute_wall_jump()
				jump_buffer_timer = 0.0
				return
			
			# Reset air jump when wall sliding starts
			if jumps_remaining == 0:
				jumps_remaining = 1
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false

func _is_same_wall(current_normal: Vector2, previous_normal: Vector2) -> bool:
	# Consider it the same wall if the normals are pointing in the same direction
	# with a small tolerance for floating point precision
	var dot_product = current_normal.dot(previous_normal)
	return dot_product > 0.8  # Threshold for considering it the same wall

func _has_wall_direction_changed(current_normal: Vector2, previous_normal: Vector2) -> bool:
	# Check if we changed from left wall to right wall or vice versa
	if previous_normal == Vector2.ZERO:
		return false  # No previous wall to compare
	
	# Left wall has positive x normal, right wall has negative x normal
	var current_is_left_wall = current_normal.x > 0
	var previous_is_left_wall = previous_normal.x > 0
	
	return current_is_left_wall != previous_is_left_wall

func _get_wall_collision() -> Dictionary:
	var result = {"is_touching": false, "normal": Vector2.ZERO}
	
	if not wall_left_raycast or not wall_right_raycast:
		return result
	
	wall_left_raycast.force_raycast_update()
	wall_right_raycast.force_raycast_update()
	
	if wall_left_raycast.is_colliding():
		result.is_touching = true
		result.normal = wall_left_raycast.get_collision_normal()
	elif wall_right_raycast.is_colliding():
		result.is_touching = true
		result.normal = wall_right_raycast.get_collision_normal()
	
	return result

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
	_activate_possession_light()

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
	var tier_skills = skills.get(tier, [Skill.MOVE, Skill.JUMP])
	if not dash_input or Skill.DASH not in tier_skills or is_dashing:
		return false
		
	var can_dash := is_on_floor() or can_dash_in_air
	if not can_dash:
		return false
		
	var dash_direction: float = direction.x if direction.x != 0.0 else (1.0 if animated_sprite.flip_h else -1.0)
	_perform_dash(dash_direction)
	
	if not is_on_floor():
		can_dash_in_air = false
	return true

func _apply_horizontal_movement(direction_x: float) -> void:
	if direction_x != 0:
		velocity.x = direction_x * ai_speed * 1.5
		_flip_to_direction(direction_x)
	else:
		velocity.x = move_toward(velocity.x, 0, ai_speed * 2.0)

func _apply_jump(jump_input: bool) -> void:
	var tier_skills = skills.get(tier, [Skill.MOVE, Skill.JUMP])
	if not (Skill.JUMP in tier_skills):
		return
	
	if jump_input:
		# Check for wall jump first
		if is_wall_sliding and Skill.WALL_CLIMB in tier_skills:
			_execute_wall_jump()
			return
		
		# Check if we can use coyote time (recently left ground)
		var can_coyote_jump = coyote_timer > 0.0 and not is_on_floor()
		# Check if we're on floor and have jumps
		var can_ground_jump = is_on_floor() and jumps_remaining > 0
		# Check if we can do air jump (double jump, etc.)
		var can_air_jump = not is_on_floor() and coyote_timer <= 0.0 and jumps_remaining > 0
		
		if can_ground_jump or can_coyote_jump or can_air_jump:
			_execute_jump()
			if can_coyote_jump:
				coyote_timer = 0.0  # Used coyote time
		else:
			# Buffer the jump for when we land OR when we start wall sliding
			jump_buffer_timer = jump_buffer_time

func _execute_jump() -> void:
	velocity.y = jump_velocity
	jumps_remaining -= 1
	
	# Debug feedback
	if coyote_timer > 0.0 and not is_on_floor():
		print("Coyote jump executed!")
	elif jump_buffer_timer > 0.0:
		print("Buffered jump executed!")
	else:
		print("Normal jump executed!")

func _execute_wall_jump() -> void:
	# Wall jump pushes away from the wall
	velocity.x = wall_normal.x * wall_jump_velocity.x
	velocity.y = wall_jump_velocity.y
	
	# Store the wall we're jumping from and start cooldown
	last_wall_normal = wall_normal
	wall_jump_cooldown_timer = wall_jump_cooldown_time
	
	# Stop wall sliding
	is_wall_sliding = false
	wall_normal = Vector2.ZERO
	
	# Consume a jump
	jumps_remaining -= 1
	
	# Flip sprite to face away from wall
	_flip_to_direction(last_wall_normal.x)

func _perform_dash(direction: float) -> void:
	is_dashing = true
	dash_timer = dash_duration
	velocity.x = direction * dash_speed
	velocity.y = 0
	_flip_to_direction(direction)


func _flip_to_direction(dir: float) -> void:
	if dir > 0:
		animated_sprite.flip_h = true   # Facing right (flip the left-facing sprite)
	elif dir < 0:
		animated_sprite.flip_h = false  # Facing left (don't flip, sprites face left by default)

func _release_control() -> void:
	# Store current velocity to preserve momentum
	var current_velocity := velocity
	
	# Stop wall sliding when releasing control
	is_wall_sliding = false
	wall_normal = Vector2.ZERO
	
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
	_deactivate_possession_light()

func _preserve_momentum_after_release(previous_velocity: Vector2) -> void:
	# Keep the velocity to maintain inertia
	velocity = previous_velocity
	
	# If we're in the air, reduce horizontal velocity slightly for natural feel
	if not is_on_floor():
		velocity.x *= 0.8  # Slight air resistance effect

func _handle_ai_patrol() -> void:
	var current_direction := get_facing_direction()
	
	# Wall climbing is only available when controlled, so AI never wall slides
	# If somehow wall sliding is active, stop it
	if is_wall_sliding:
		is_wall_sliding = false
	
	if _should_turn_around(current_direction):
		_turn_around()
		# If we couldn't turn around due to cooldown, stop moving
		if flip_cooldown_timer > 0.0:
			velocity.x = 0.0
			return
		current_direction *= -1
	
	# Only move if we're not in flip cooldown or if we can move safely
	if flip_cooldown_timer <= 0.0 or not _should_turn_around(current_direction):
		velocity.x = current_direction * ai_speed
	else:
		velocity.x = 0.0

func _should_turn_around(direction: float) -> bool:
	return _has_edge_ahead(direction) or _has_wall_ahead(direction)

func _has_edge_ahead(direction: float) -> bool:
	if not edge_raycast:
		return false
		
	edge_raycast.target_position = Vector2(24 * direction, 32)
	edge_raycast.force_raycast_update()
	
	return is_on_floor() and not edge_raycast.is_colliding()

func _has_wall_ahead(direction: float) -> bool:
	if not wall_raycast:
		return false
		
	wall_raycast.target_position = Vector2(8.1 * direction, 0)
	wall_raycast.force_raycast_update()
	
	return wall_raycast.is_colliding()

func _turn_around() -> void:
	# Check if we're still in flip cooldown
	if flip_cooldown_timer > 0.0:
		return
	
	var current_direction := get_facing_direction()
	var new_direction = -current_direction
	
	# Avoid flipping back to the same direction we just came from
	if new_direction == last_flip_direction and flip_cooldown_timer > 0.0:
		return
	
	_flip_to_direction(new_direction)
	last_flip_direction = new_direction
	flip_cooldown_timer = flip_cooldown_time

func _handle_inert_movement() -> void:
	velocity.x = move_toward(velocity.x, 0, ai_speed * 2.0)

func destroy_chip() -> void:
	chip_destroyed = true
	if current_state != State.CONTROLLED:
		current_state = State.INERT
		_update_visual_state()
		_generate_damage_particles()
	
	# Drop weapon when chip is destroyed
	if weapon_instance:
		_drop_weapon_on_destroy()

func _drop_weapon_on_destroy() -> void:
	if weapon_instance and weapon_instance.is_held:
		weapon_instance.drop()
		weapon_instance = null

func _update_visual_state() -> void:
	match current_state:
		State.AI:
			# Different colors for each tier
			match tier:
				1:
					animated_sprite.modulate = tier_1_color
				2:
					animated_sprite.modulate = tier_2_color
				3:
					animated_sprite.modulate = tier_3_color
				_:
					animated_sprite.modulate = tier_4_color
		State.INERT:
			animated_sprite.modulate = inert_color
		State.CONTROLLED:
			animated_sprite.modulate = controlled_color
	
	# Force animation update when state changes
	_update_animation()

func get_facing_direction() -> float:
	# Sprites face left by default, so flip_h = false means facing left (-1), flip_h = true means facing right (1)
	return 1.0 if animated_sprite.flip_h else -1.0

func take_damage(_damage_amount: float) -> void:
	match current_state:
		State.CONTROLLED:
			_release_control()
		State.AI:
			destroy_chip()
		State.INERT:
			pass  # Already destroyed, no effect

# =============================================================================
# ANIMATION MANAGEMENT
# Note: All sprites face LEFT by default
# flip_h = false = facing left (-1)
# flip_h = true = facing right (1) 
# =============================================================================
func _update_animation() -> void:
	if not animated_sprite:
		return
	
	var target_animation := _get_target_animation()
	if animated_sprite.animation != target_animation:
		animated_sprite.play(target_animation)
	
	# Update eyes animation only when CONTROLLED
	_update_eyes_animation(target_animation)
	
	# Update sprite flip - do this after setting animation to avoid conflicts
	call_deferred("_update_sprite_flip")

func _get_target_animation() -> String:
	# Priority order: Dash > Wall Slide > Jump/Fall > Movement > State-based > Idle
	
	if is_dashing:
		return "Dash"
	
	if is_wall_sliding:
		return "WallSlide"
	
	if not is_on_floor():
		if velocity.y < -50:  # Going up with significant speed
			return "Jump"
		elif velocity.y > 50:  # Falling with significant speed
			return "Fall"
	
	if current_state == State.INERT:
		return "Inert"
	
	# Movement animations - check for any horizontal movement
	if abs(velocity.x) > 5:  # Moving horizontally
		return "MoveLeft"  # Base animation is facing left, we'll flip for right movement
	
	# Default idle state - check if Idle animation exists, otherwise use first frame of MoveLeft
	var sprite_frames = animated_sprite.sprite_frames
	if sprite_frames and sprite_frames.has_animation("Idle"):
		return "Idle"
	else:
		return "MoveLeft"  # Fallback to first frame of MoveLeft as idle

func _update_sprite_flip() -> void:
	if not animated_sprite:
		return
	
	# Store current flip state to avoid unnecessary changes
	var current_flip := animated_sprite.flip_h
	var should_flip_right := current_flip  # Default to keeping current state
	
	if current_state == State.CONTROLLED:
		# When controlled, use input direction
		var direction := InputManager.get_movement_input()
		if abs(direction.x) > 0.1:  # Only change direction with actual input
			should_flip_right = direction.x > 0  # Flip when moving right (sprites face left by default)
	elif current_state == State.AI:
		# When AI, use movement direction but with threshold
		if abs(velocity.x) > 20:  # Higher threshold to avoid flickering
			should_flip_right = velocity.x > 0  # Flip when moving right
	# For INERT state, keep current direction
	
	# Only update if there's actually a change needed
	if current_flip != should_flip_right:
		animated_sprite.flip_h = should_flip_right
		# Sync eyes flip when body flip changes
		if eyes_sprite and current_state == State.CONTROLLED:
			eyes_sprite.flip_h = should_flip_right

func _update_eyes_animation(body_animation: String) -> void:
	if not eyes_sprite:
		return
	
	# Eyes only animate when in CONTROLLED state
	if current_state != State.CONTROLLED:
		# Hide eyes or stop animation when not controlled
		if eyes_sprite.visible:
			eyes_sprite.visible = false
			print("Enemy: Eyes hidden - not controlled")
		return
	
	# Show eyes when controlled
	if not eyes_sprite.visible:
		eyes_sprite.visible = true
		print("Enemy: Eyes shown - controlled state")
	
	# Sync eyes animation with body animation
	# Skip "Inert" animation for eyes since they shouldn't show when inert
	var target_eyes_animation := body_animation
	if target_eyes_animation == "Inert":
		eyes_sprite.visible = false
		print("Enemy: Eyes hidden - inert animation")
		return
	
	# Play the corresponding eyes animation
	if eyes_sprite.sprite_frames and eyes_sprite.sprite_frames.has_animation(target_eyes_animation):
		if eyes_sprite.animation != target_eyes_animation:
			eyes_sprite.play(target_eyes_animation)
			print("Enemy: Eyes animation changed to: ", target_eyes_animation)
	else:
		print("Enemy: Eyes animation not found: ", target_eyes_animation)
	
	# Sync eyes flip with body flip
	call_deferred("_sync_eyes_flip")

func _sync_eyes_flip() -> void:
	if not eyes_sprite or not animated_sprite:
		return
	
	# Eyes should always match the body flip direction
	if eyes_sprite.flip_h != animated_sprite.flip_h:
		eyes_sprite.flip_h = animated_sprite.flip_h
		print("Enemy: Eyes flip synced with body - flip_h: ", eyes_sprite.flip_h)

# =============================================================================
# POSSESSION LIGHTING EFFECTS
# =============================================================================
func _activate_possession_light() -> void:
	if light:
		light.enabled = true
		light.energy = 1.5  # Less intense than Orb (which uses 2.0+)
		print("Enemy: Possession light activated")
	else:
		print("Enemy: Warning - PointLight2D not found!")

func _deactivate_possession_light() -> void:
	if light:
		light.enabled = false
		print("Enemy: Possession light deactivated")
	else:
		print("Enemy: Warning - PointLight2D not found!")

# =============================================================================
# DAMAGE PARTICLE EFFECTS
# =============================================================================
func _generate_damage_particles() -> void:
	if not damage_particles:
		print("Enemy: Warning - DamageParticles not found!")
		return
	
	# Get the current modulate color of the enemy sprite
	var enemy_color = animated_sprite.modulate
	
	# Apply the enemy's color to the particles
	var particle_material = damage_particles.process_material as ParticleProcessMaterial
	if particle_material:
		particle_material.color = enemy_color
		print("Enemy: Damage particles generated with color: ", enemy_color)
	
	# Trigger the particle burst
	damage_particles.restart()
	damage_particles.emitting = true
