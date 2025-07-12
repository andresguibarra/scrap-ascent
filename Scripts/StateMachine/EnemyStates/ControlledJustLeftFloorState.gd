extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

var floor_coyote_timer: float = 0.0

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.set_animation("Fall")
	floor_coyote_timer = enemy.coyote_time
	
	# If we have a jump buffer and can still jump, do it immediately
	if enemy.has_jump_buffer() and enemy.can_jump():
		finished.emit(CONTROLLED_JUMP)

func handle_input(_event: InputEvent) -> void:
	if enemy.is_controlled() and InputManager.is_possess_just_pressed():
		enemy.release_control()

func physics_update(delta: float) -> void:
	var direction: Vector2 = InputManager.get_movement_input()
	var jump: bool = InputManager.is_jump_just_pressed()
	var dash: bool = InputManager.is_dash_just_pressed()
	
	# Update coyote timer
	floor_coyote_timer -= delta
	
	# Handle horizontal movement
	if direction.x != 0:
		enemy.velocity.x = direction.x * enemy.ai_speed
		enemy.update_sprite_flip()
	else:
		enemy.velocity.x = move_toward(enemy.velocity.x, 0, enemy.ai_speed * 2.0)
	
	# Priority 1: Dash (if available and pressed)
	if dash and enemy.can_dash():
		finished.emit(CONTROLLED_DASH)
		return
	
	# Priority 2: Coyote Jump (if we still have coyote time and can jump)
	if jump and floor_coyote_timer > 0.0:
		finished.emit(CONTROLLED_JUMP)
		return
	
	# Priority 3: Wall Slide (if pressing toward wall and against wall)
	if direction.x != 0 and enemy.is_against_wall(true) and enemy.has_skill(Enemy.Skill.WALL_CLIMB):
		finished.emit(CONTROLLED_WALL_SLIDE)
		return
	
	# Priority 4: Ground landing (returned to floor)
	if enemy.is_on_floor():
		if abs(enemy.velocity.x) > 5:
			finished.emit(CONTROLLED_MOVE)
		else:
			finished.emit(CONTROLLED_IDLE)
		return
	
	# Priority 5: Coyote time expired - go to regular fall
	if floor_coyote_timer <= 0.0:
		finished.emit(CONTROLLED_FALL)
		return
	
	# Apply gravity and movement
	enemy.apply_movement_and_gravity(delta)
