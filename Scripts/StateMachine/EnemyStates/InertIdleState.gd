extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.chip_destroyed = true
	enemy.set_animation("Inert")

func physics_update(delta: float) -> void:
	# Apply gravity so inert enemies can fall off platforms
	enemy.velocity = Vector2.ZERO
	apply_gravity_and_movement(delta)
	
	# Direct transition check - if not on floor, go to fall
	if not enemy.is_on_floor():
		finished.emit(INERT_FALL)
