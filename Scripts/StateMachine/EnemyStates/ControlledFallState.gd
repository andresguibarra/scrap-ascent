extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.set_animation("Fall")
	if enemy.can_wall_jump() and enemy.has_jump_buffer() and enemy.can_jump():
		finished.emit(CONTROLLED_JUMP)

func handle_input(_event: InputEvent) -> void:
	if enemy.is_controlled() and InputManager.is_possess_just_pressed():
		enemy.release_control()

func physics_update(delta: float) -> void:
	var direction: Vector2 = InputManager.get_movement_input()
	var jump: bool = InputManager.is_jump_just_pressed()
	var dash: bool = InputManager.is_dash_just_pressed()
	
	# Handle horizontal movement
	if direction.x != 0:
		enemy.velocity.x = direction.x * enemy.ai_speed
		enemy.update_sprite_flip()
	if direction.x == 0:
		enemy.velocity.x = 0
		
	
	# Handle input for state transitions
	if jump:
		enemy.set_jump_buffer()
		if enemy.can_double_jump():
			finished.emit(CONTROLLED_DOUBLE_JUMP)
			return
		elif enemy.can_jump():
			finished.emit(CONTROLLED_JUMP)
			return
		
	if dash and enemy.can_dash():
		finished.emit(CONTROLLED_DASH)
		return
	
	# Check for wall slide - check both current state and near-wall state
	if direction.x != 0 and enemy.has_skill(Enemy.Skill.WALL_CLIMB):
		# Try to transition to wall slide if against wall or moving toward a wall
		if enemy.is_against_wall(true) and not enemy.is_same_wall_as_before():
			finished.emit(CONTROLLED_WALL_SLIDE)
			return
	
	apply_gravity_and_movement(delta)
	
	
	# Check for ground landing transitions
	if enemy.is_on_floor():
		if abs(enemy.velocity.x) > 5:
			finished.emit(CONTROLLED_MOVE)
		else:
			finished.emit(CONTROLLED_IDLE)
		return
