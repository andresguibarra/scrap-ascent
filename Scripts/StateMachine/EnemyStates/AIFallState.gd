extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.set_animation("Jump")

func physics_update(delta: float) -> void:
	apply_gravity_and_movement(delta)
	
	var movement_transition = check_movement_transitions()
	if movement_transition != "":
		finished.emit(movement_transition)
