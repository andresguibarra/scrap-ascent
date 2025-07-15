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
const CONTROLLED_JUST_LEFT_FLOOR = "ControlledJustLeftFloorState"

const INERT_IDLE = "InertIdleState"
const INERT_FALL = "InertFallState"

var enemy: Enemy

func _ready() -> void:
	# Set enemy reference more directly
	if owner and owner is Enemy:
		enemy = owner as Enemy
		# Commented out initialization log - only showing initial state and transitions
		# var state_display = _format_state_name(name)
		# print_rich("[color=magenta]⚡ EnemyState:[/color] [color=yellow]%s[/color] [color=lime]initialized with enemy:[/color] [color=cyan]%s[/color]" % [state_display, enemy.name])


# Helper methods for all states
func apply_gravity_and_movement(delta: float) -> void:
	if not enemy:
		return
	enemy.apply_movement_and_gravity(delta)

func _format_state_name(state_name: String) -> String:
	# Remove "State" suffix if present
	var clean_name = state_name.replace("State", "")
	
	# Add spaces before capital letters for better readability
	var result = ""
	for i in range(clean_name.length()):
		var character = clean_name[i]
		if i > 0 and character.to_upper() == character and clean_name[i-1].to_upper() != character:
			result += " "
		result += character
	
	return result
