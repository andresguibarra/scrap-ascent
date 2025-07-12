extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

var idle_timer: float = 0.0
var max_idle_time: float = 0.5

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.set_animation("Idle")
	idle_timer = 0.0

func physics_update(delta: float) -> void:
	if enemy:
		enemy.velocity.x = move_toward(enemy.velocity.x, 0, enemy.ai_speed * 2.0)
	apply_gravity_and_movement(delta)
	
	# Increment idle timer
	idle_timer += delta
	
	# Auto-transition to move state after max_idle_time
	if not enemy.is_on_floor():
		finished.emit(EnemyState.AI_FALL)
		return
	
	if idle_timer >= max_idle_time:
		finished.emit(EnemyState.AI_MOVE)
		return
