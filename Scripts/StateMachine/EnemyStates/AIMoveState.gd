extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.set_animation("MoveLeft")

func physics_update(delta: float) -> void:
	# Apply AI patrol movement
	var direction = get_ai_patrol_direction()
	
	enemy.velocity.x = direction * enemy.ai_speed
	enemy.update_sprite_flip()
	
	apply_gravity_and_movement(delta)
	
	# Check for movement transitions
	var movement_transition = check_movement_transitions()
	if movement_transition != "":
		finished.emit(movement_transition)
		
# UTILITY METHODS FOR AI STATES
func get_ai_patrol_direction() -> float:
	var direction = 1.0 if enemy.face_right else -1.0
	
	# Check if we should flip at edge
	if enemy.is_at_edge():
		return -direction
	
	# Check for wall collision
	if enemy.is_against_wall(false):
		return -direction
	
	return direction
