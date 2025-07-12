extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.chip_destroyed = true
	enemy.set_animation("Inert")

func physics_update(delta: float) -> void:
	# enemy.velocity.x = move_toward(enemy.velocity.x, 0, enemy.ai_speed * 2.0)
	#apply_gravity_and_movement(delta)
	pass
	# var movement_transition = check_movement_transitions()
	# if movement_transition != "":
	# 	finished.emit(movement_transition)
