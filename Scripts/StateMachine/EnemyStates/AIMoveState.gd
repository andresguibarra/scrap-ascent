extends "res://Scripts/StateMachine/EnemyStates/EnemyState.gd"

var direction_change_timer: float = 0.0
var direction_change_count: int = 0
var last_direction: float = 1.0

func enter(_previous_state_path: String, _data := {}) -> void:
	enemy.set_animation("MoveLeft")
	direction_change_timer = 0.0
	direction_change_count = 0
	last_direction = 1.0 if enemy.face_right else -1.0

func physics_update(delta: float) -> void:
	# Update timer
	direction_change_timer += delta
	
	# Apply AI patrol movement
	var direction = get_ai_patrol_direction()
	
	# Check if direction changed
	if direction != last_direction:
		direction_change_count += 1
		last_direction = direction
		
		# Check if trapped (2 direction changes within 100ms)
		if direction_change_count >= 2 and direction_change_timer <= 0.1:
			finished.emit(EnemyState.AI_IDLE)
			return
	
	# Reset counter if more than 100ms passed
	if direction_change_timer > 0.1:
		direction_change_timer = 0.0
		direction_change_count = 0
	
	enemy.velocity.x = direction * enemy.ai_speed
	enemy.update_sprite_flip()
	apply_gravity_and_movement(delta)
	
	if not enemy.is_on_floor():
		finished.emit(EnemyState.AI_FALL)
		
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
