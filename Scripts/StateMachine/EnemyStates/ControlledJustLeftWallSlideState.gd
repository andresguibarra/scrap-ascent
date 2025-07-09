extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

var wall_coyote_timer: float = 0.0

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.set_animation("Fall")
	wall_coyote_timer = enemy.coyote_time
	if enemy.can_wall_jump() and enemy.has_jump_buffer():
		finished.emit(CONTROLLED_JUMP)

func handle_input(_event: InputEvent) -> void:
	if enemy.is_controlled() and InputManager.is_possess_just_pressed():
		enemy.release_control()

func physics_update(delta: float) -> void:
	var direction: Vector2 = InputManager.get_movement_input()
	var jump: bool = InputManager.is_jump_just_pressed()
	var dash: bool = InputManager.is_dash_just_pressed()
	
	# Update coyote timer
	wall_coyote_timer -= delta
	
	# Handle horizontal movement
	if direction.x != 0:
		enemy.velocity.x = direction.x * enemy.ai_speed
		enemy.update_sprite_flip()
	else:
		enemy.velocity.x = 0 
	
	# Priority 1: Dash (if available and pressed)
	if dash and enemy.can_dash():
		finished.emit(CONTROLLED_DASH)
		return
	
	# Priority 2: Wall Jump (if we have buffer and can wall jump)
	if jump and enemy.can_wall_jump():
		finished.emit(CONTROLLED_JUMP)
		return
	
	# Priority 3: Return to Wall Slide (if pressing toward wall and against wall)
	if direction.x != 0 and enemy.is_against_wall() and enemy.has_skill(Enemy.Skill.WALL_CLIMB):
		finished.emit(CONTROLLED_WALL_SLIDE)
		return
	
	# Priority 4: Ground landing
	if enemy.is_on_floor():
		finished.emit(CONTROLLED_IDLE)
		return
	
	# Priority 5: Coyote time expired - go to regular fall
	if wall_coyote_timer <= 0.0:
		finished.emit(CONTROLLED_FALL)
		return
	
	# Apply gravity and movement
	enemy.apply_movement_and_gravity(delta)
