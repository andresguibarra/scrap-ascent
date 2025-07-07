extends Node

# Centralized input manager for Scrap Ascent
# Following typed GDScript practices

var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size

func is_move_left_pressed() -> bool:
	return Input.is_action_pressed("move_left")

func is_move_right_pressed() -> bool:
	return Input.is_action_pressed("move_right")

func is_jump_just_pressed() -> bool:
	return Input.is_action_just_pressed("jump")

func is_possess_just_pressed() -> bool:
	return Input.is_action_just_pressed("possess")

func is_shoot_just_pressed() -> bool:
	return Input.is_action_just_pressed("shoot")
	
func is_dash_just_pressed()-> bool: 
	return Input.is_action_just_pressed("dash")

func is_weapon_toggle_just_pressed() -> bool:
	return Input.is_action_just_pressed("weapon_toggle")

func is_restart_pressed() -> bool:
	return Input.is_action_pressed("restart")

func is_restart_just_pressed() -> bool:
	return Input.is_action_just_pressed("restart")

func is_only_restart_input_active() -> bool:
	# For win screen - ONLY allow restart input, block everything else
	if is_restart_just_pressed():
		return true
	
	# Block all other inputs by checking if any non-restart action is pressed
	if (is_move_left_pressed() or is_move_right_pressed() or 
		is_jump_just_pressed() or is_possess_just_pressed() or 
		is_shoot_just_pressed() or is_dash_just_pressed() or 
		is_weapon_toggle_just_pressed()):
		return false
	
	# Also block any raw key inputs that aren't restart
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_ENTER):
		return false
	
	return false

func get_movement_input() -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	
	if is_move_left_pressed():
		direction.x -= 1.0
	if is_move_right_pressed():
		direction.x += 1.0
	
	return direction

func get_screen_size() -> Vector2:
	return screen_size
