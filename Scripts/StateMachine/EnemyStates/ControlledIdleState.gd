extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.set_animation("Idle")
	enemy.reset_air_abilities()  # Reset air abilities when landing

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
		# Change to move animation if moving
		enemy.set_animation("MoveLeft")
	else:
		enemy.velocity.x = 0
		# Change back to idle if not moving
		enemy.set_animation("Idle")
		enemy.update_sprite_flip()
		
	
	# Handle input for state transitions
	if jump and enemy.has_skill(Enemy.Skill.JUMP):
		finished.emit(CONTROLLED_JUMP)
		return
		
	if dash and enemy.has_skill(Enemy.Skill.DASH):
		finished.emit(CONTROLLED_DASH)
		return
	
	apply_gravity_and_movement(delta)
	
	var movement_transition = check_movement_transitions()
	if movement_transition != "":
		finished.emit(movement_transition)
