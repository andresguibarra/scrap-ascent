extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.set_animation("WallSlide")
	if enemy.wall_slide_sound:
		enemy.play_sound(enemy.wall_slide_sound)
	# Wall slide physics: constant downward speed
	enemy.velocity.y = enemy.wall_slide_speed

func handle_input(_event: InputEvent) -> void:
	if enemy.is_controlled() and InputManager.is_possess_just_pressed():
		enemy.release_control()

func physics_update(delta: float) -> void:
	var direction: Vector2 = InputManager.get_movement_input()
	var jump: bool = InputManager.is_jump_just_pressed()
	var dash: bool = InputManager.is_dash_just_pressed()
	
	# Prevent going up during wall slide
	if enemy.velocity.y < 0:
		enemy.velocity.y = 0
	
	# Check if player is pressing toward the wall
	var input_toward_wall = false
	if enemy.face_right and direction.x > 0:
		input_toward_wall = true
	elif not enemy.face_right and direction.x < 0:
		input_toward_wall = true
	
	# Exit to fall state if not pressing toward wall
	if not input_toward_wall:
		finished.emit(CONTROLLED_FALL)
		return
	
	# Handle input for state transitions
	if jump and enemy.can_wall_jump():
		finished.emit(CONTROLLED_JUMP)
		return
		
	if dash and enemy.can_dash():
		finished.emit(CONTROLLED_DASH)
		return
	
	enemy.move_and_slide()
	
	# Exit wall slide if no longer against wall
	if not enemy.is_against_wall():
		if enemy.is_on_floor():
			finished.emit(CONTROLLED_IDLE)
		else:
			finished.emit(CONTROLLED_FALL)
		return
