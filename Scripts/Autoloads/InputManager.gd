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

func get_movement_input() -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	
	if is_move_left_pressed():
		direction.x -= 1.0
	if is_move_right_pressed():
		direction.x += 1.0
	
	return direction

func is_air_dash_input() -> bool:
	return (is_move_left_pressed() or is_move_right_pressed()) and is_jump_just_pressed()

func get_air_dash_direction() -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	
	if is_move_left_pressed():
		direction.x = -1.0
	elif is_move_right_pressed():
		direction.x = 1.0
	
	return direction

func get_screen_size() -> Vector2:
	return screen_size
