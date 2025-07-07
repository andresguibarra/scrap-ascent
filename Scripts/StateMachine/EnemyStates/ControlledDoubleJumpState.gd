extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

func enter(_previous_state_path: String, _data := {}) -> void:
	if enemy:
		enemy.velocity.y = enemy.jump_velocity
		enemy.play_sound(enemy.double_jump_sound)
		enemy.set_animation("Jump")
		enemy.use_double_jump()  # Marcar que ya usó el double jump

func handle_input(_event: InputEvent) -> void:
	if enemy.is_controlled() and InputManager.is_possess_just_pressed():
		enemy.release_control()

func physics_update(delta: float) -> void:
	var direction: Vector2 = InputManager.get_movement_input()
	var dash: bool = InputManager.is_dash_just_pressed()
	# NO manejar jump input aquí - ya no se puede saltar después del double jump

	# Handle horizontal movement
	if direction.x != 0:
		enemy.velocity.x = direction.x * enemy.ai_speed
		enemy.update_sprite_flip()
	else:
		enemy.velocity.x = 0

	# Check for dash transition
	if dash and enemy.can_dash():
		finished.emit(CONTROLLED_DASH)
		return

	# Check for wall slide
	if direction.x != 0 and enemy.is_against_wall() and enemy.has_skill(Enemy.Skill.WALL_CLIMB):
		finished.emit(CONTROLLED_WALL_SLIDE)
		return

	apply_gravity_and_movement(delta)

	# If landed, go to idle
	if enemy.is_on_floor():
		finished.emit(CONTROLLED_IDLE)
		return

	# If falling, go to fall
	if enemy.velocity.y > 0:
		finished.emit(CONTROLLED_FALL)
		return
