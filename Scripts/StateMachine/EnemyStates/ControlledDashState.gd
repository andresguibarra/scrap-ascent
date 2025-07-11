extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

var dash_timer: float = 0.0

func enter(_previous_state_path: String, _data := {}) -> void:
	if enemy:
		# Get dash direction from input or facing direction
		var input_dir = InputManager.get_movement_input()
		var dash_direction: Vector2
		
		if input_dir.length() > 0:
			dash_direction = input_dir.normalized()
		else:
			dash_direction = Vector2(enemy.get_facing_direction(), 0)
		
		# Set dash velocity
		enemy.velocity = dash_direction * enemy.dash_speed
		
		# Initialize dash timer
		dash_timer = enemy.dash_duration
		
		# Mark dash as used
		enemy.use_dash()
		
		# Play effects
		enemy.play_sound(enemy.dash_sound)
		enemy.set_animation("Dash")

func handle_input(_event: InputEvent) -> void:
	if enemy.is_controlled() and InputManager.is_possess_just_pressed():
		enemy.release_control()

func physics_update(delta: float) -> void:
	dash_timer -= delta
	
	# NO gravity during dash - maintain current velocity
	# Do not call apply_gravity_and_movement()
	enemy.move_and_slide()
	
	# End dash when timer expires
	if dash_timer <= 0:
		if enemy.is_on_floor():
			finished.emit(CONTROLLED_IDLE)
		else:
			finished.emit(CONTROLLED_FALL)
		return
	
