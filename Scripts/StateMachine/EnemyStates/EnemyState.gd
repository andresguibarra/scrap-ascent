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
	else:
		print_rich("[color=orange]⚠️ EnemyState Warning:[/color] [color=white]Owner is not an Enemy:[/color] [color=gray]%s[/color]" % str(owner))
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
			# Commented out - only showing state transitions
			# var state_display = _format_state_name(name)
			# print_rich("[color=magenta]⚡ EnemyState:[/color] [color=yellow]%s[/color] [color=lime]found enemy:[/color] [color=cyan]%s[/color]" % [state_display, enemy.name])
			return
		current = current.get_parent()
	
	# If we still haven't found it, it might be the owner of the state machine
	if not enemy and owner and owner is Enemy:
		enemy = owner as Enemy
		# Commented out - only showing state transitions
		# var state_display = _format_state_name(name)
		# print_rich("[color=magenta]⚡ EnemyState:[/color] [color=yellow]%s[/color] [color=lime]found enemy via owner:[/color] [color=cyan]%s[/color]" % [state_display, enemy.name])
	
	if not enemy:
		print_rich("[color=red]❌ EnemyState ERROR:[/color] [color=white]Could not find Enemy reference for[/color] [color=gray]%s[/color]" % name)

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
	
	# For INERT states
	if current_name.begins_with("Inert"):
		if enemy.is_on_floor():
			if current_name != "InertIdleState":
				return INERT_IDLE
		else:
			if current_name != "InertFallState":
				return INERT_FALL
	
	return ""

func _format_state_name(state_name: String) -> String:
	# Remove "State" suffix if present
	var clean_name = state_name.replace("State", "")
	
	# Add spaces before capital letters for better readability
	var result = ""
	for i in range(clean_name.length()):
		var char = clean_name[i]
		if i > 0 and char.to_upper() == char and clean_name[i-1].to_upper() != char:
			result += " "
		result += char
	
	return result
