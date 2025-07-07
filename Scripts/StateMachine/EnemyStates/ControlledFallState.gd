extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.set_animation("Jump")

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
		if enemy.can_double_jump():
			finished.emit(CONTROLLED_DOUBLE_JUMP)
			return
		elif enemy.can_wall_jump():
			finished.emit(CONTROLLED_JUMP)
			return
		# NO permitir ningún tipo de salto si ya usó double jump y no hay wall jump
		
	if dash and enemy.can_dash():
		finished.emit(CONTROLLED_DASH)
		return
	
	# Check for wall slide
	if direction.x != 0 and enemy.is_against_wall() and enemy.has_skill(Enemy.Skill.WALL_CLIMB):
		finished.emit(CONTROLLED_WALL_SLIDE)
		return
	
	apply_gravity_and_movement(delta)
	
	var movement_transition = check_movement_transitions()
	if movement_transition != "":
		finished.emit(movement_transition)
