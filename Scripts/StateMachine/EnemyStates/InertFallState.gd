extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.chip_destroyed = true
	enemy.set_animation("Inert")

func physics_update(delta: float) -> void:
	apply_gravity_and_movement(delta)
	
	# Direct transition check - if on floor, go to idle
	if enemy.is_on_floor():
		finished.emit(INERT_IDLE)
