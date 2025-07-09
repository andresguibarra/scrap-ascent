extends "res://Scripts/StateMachine/State.gd"
class_name EnemyState

# Main behavior states
const AI_IDLE = "AIIdleState"
const AI_MOVE = "AIMoveState"
const AI_JUMP = "AIJumpState"
const AI_FALL = "AIFallState"

const CONTROLLED_IDLE = "ControlledIdleState"
const CONTROLLED_MOVE = "ControlledMoveState"
const CONTROLLED_JUMP = "ControlledJumpState"
const CONTROLLED_DOUBLE_JUMP = "ControlledDoubleJumpState"
const CONTROLLED_FALL = "ControlledFallState"
const CONTROLLED_DASH = "ControlledDashState"
const CONTROLLED_WALL_SLIDE = "ControlledWallSlideState"
const CONTROLLED_JUST_LEFT_WALL_SLIDE = "ControlledJustLeftWallSlideState"

const INERT_IDLE = "InertIdleState"
const INERT_FALL = "InertFallState"

var enemy: Enemy

func _ready() -> void:
	# Set enemy reference more directly
	if owner and owner is Enemy:
		enemy = owner as Enemy
		print("EnemyState: ", name, " initialized with enemy: ", enemy.name)
	else:
		print("EnemyState Warning: Owner is not an Enemy: ", owner)
		# Try to find the Enemy in the scene tree
		call_deferred("_find_enemy")

func _find_enemy() -> void:
	if enemy:
		return
		
	# Try to find the Enemy node by traversing up the tree
	var current = self
	while current:
		if current is Enemy:
			enemy = current as Enemy
			print("EnemyState: ", name, " found enemy: ", enemy.name)
			return
		current = current.get_parent()
	
	# If we still haven't found it, it might be the owner of the state machine
	if not enemy and owner and owner is Enemy:
		enemy = owner as Enemy
		print("EnemyState: ", name, " found enemy via owner: ", enemy.name)
	
	if not enemy:
		print("EnemyState ERROR: Could not find Enemy reference for ", name)

# Helper methods for all states
func apply_gravity_and_movement(delta: float) -> void:
	if not enemy:
		return
	enemy.apply_movement_and_gravity(delta)

# Common transition checks


func check_movement_transitions() -> String:
	if not enemy:
		return ""
		
	# Check movement-based transitions based on current state name and physics
	var current_name = name
	
	# For AI states
	if current_name.begins_with("AI"):
		if enemy.is_on_floor():
			if abs(enemy.velocity.x) > 5 and current_name != "AIMoveState":
				return AI_MOVE
			elif abs(enemy.velocity.x) <= 5 and current_name != "AIIdleState":
				return AI_IDLE
		else:
			if enemy.velocity.y < -50 and current_name != "AIJumpState":
				return AI_JUMP
			elif enemy.velocity.y >= -50 and current_name != "AIFallState":
				return AI_FALL
	# For INERT states
	elif current_name.begins_with("Inert"):
		if enemy.is_on_floor():
			if current_name != "InertIdleState":
				return INERT_IDLE
		else:
			if current_name != "InertFallState":
				return INERT_FALL
	
	return ""
