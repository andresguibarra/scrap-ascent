extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

func enter(_previous_state_path: String, _data := {}) -> void:
	if enemy:
		enemy.velocity.y = enemy.jump_velocity
		enemy.play_sound(enemy.jump_sound)
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
	
	apply_gravity_and_movement(delta)
	
	var movement_transition = check_movement_transitions()
	if movement_transition != "":
		finished.emit(movement_transition)
