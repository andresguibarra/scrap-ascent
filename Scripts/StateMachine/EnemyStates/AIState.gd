extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.current_state = Enemy.State.AI
	enemy._update_visual_state()

func physics_update(delta: float) -> void:
	update_timers_and_physics(delta)
	enemy._handle_ai_patrol()
	apply_gravity_and_movement(delta)
	
	var new_state = check_state_transitions()
	if new_state != "":
		finished.emit(new_state)
