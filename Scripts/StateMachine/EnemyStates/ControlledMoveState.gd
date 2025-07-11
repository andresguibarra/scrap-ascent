extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.set_animation("MoveLeft")
	enemy.reset_air_abilities()  # Reset air abilities when landing
	enemy.reset_wall_jump_cooldown()  # Reset wall jump cooldown when landing
	
	# Check if we have a buffered jump
	if enemy.has_jump_buffer():
		finished.emit(CONTROLLED_JUMP)
		return

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
		# Ensure move animation is playing
		enemy.set_animation("MoveLeft")
	else:
		enemy.velocity.x = 0
		# Change to idle if not moving
		enemy.set_animation("Idle")
	
	# Handle input for state transitions
	if jump and enemy.has_skill(Enemy.Skill.JUMP):
		finished.emit(CONTROLLED_JUMP)
		return
		
	if dash and enemy.has_skill(Enemy.Skill.DASH):
		finished.emit(CONTROLLED_DASH)
		return
	
	apply_gravity_and_movement(delta)
	
	# Check for transitions based on movement and physics
	if not enemy.is_on_floor():
		finished.emit(CONTROLLED_FALL)
		return
	
	# Transition to idle if not moving
	if abs(enemy.velocity.x) <= 5:
		finished.emit(CONTROLLED_IDLE)
		return
