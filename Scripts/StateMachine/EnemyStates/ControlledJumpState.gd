extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

func enter(_previous_state_path: String, _data := {}) -> void:
	if enemy:
		enemy.velocity.y = enemy.jump_velocity
		enemy.play_sound(enemy.jump_sound)
		enemy.set_animation("Jump")
		enemy.set_wall_jump_cooldown()
		# Consume the jump buffer when we actually jump
		enemy.consume_jump_buffer()

func handle_input(_event: InputEvent) -> void:
	if enemy.is_controlled() and InputManager.is_possess_just_pressed():
		enemy.release_control()

func physics_update(delta: float) -> void:
	var direction: Vector2 = InputManager.get_movement_input()
	var jump: bool = InputManager.is_jump_just_pressed()
	var dash: bool = InputManager.is_dash_just_pressed()
	
	if enemy.wall_jump_cooldown > 0.0:
		enemy.wall_jump_cooldown -= delta
	
	# Apply ceiling corner correction while jumping upward
	if enemy.velocity.y < 0:
		enemy.apply_ceiling_corner_correction()
	
	# Handle horizontal movement
	if direction.x != 0:
		enemy.velocity.x = direction.x * enemy.ai_speed
		enemy.update_sprite_flip()
	else:
		enemy.velocity.x = 0
	
	# Check for double jump transition
	if jump and enemy.has_skill(Enemy.Skill.DOUBLE_JUMP):
		finished.emit(CONTROLLED_DOUBLE_JUMP)
		return
	
	# Check for dash transition
	if dash and enemy.can_dash():
		finished.emit(CONTROLLED_DASH)
		return
	
	# Check for transitions based on movement and physics
	#if enemy.is_on_floor():
		#if abs(enemy.velocity.x) > 5:
			#finished.emit(CONTROLLED_MOVE)
		#else:
			#finished.emit(CONTROLLED_IDLE)
		#return
	
	# Transition to fall when moving downward
	if enemy.velocity.y >= -50:
		finished.emit(CONTROLLED_FALL)
		return
	
	apply_gravity_and_movement(delta)

