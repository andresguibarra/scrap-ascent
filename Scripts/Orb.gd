extends CharacterBody2D

@export var speed := 200.0
@export var possession_range := 100.0  # Increased for testing
var controlled = true
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	name = "Orb"
	add_to_group("player")

func _physics_process(delta: float) -> void:
	var direction: Vector2 = InputManager.get_movement_input()
	
	# Orb horizontal movement
	if direction.x != 0:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 2.0)
	
	# Apply gravity always
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if controlled and InputManager.is_possess_just_pressed():
		print("Orb: attempting possession")
		_attempt_possession()
		get_viewport().set_input_as_handled()

func _attempt_possession() -> void:
	var enemy := _find_nearest_enemy()
	if enemy:
		controlled = false  # Reset orb control state
		enemy.posses()
		queue_free()

func _find_nearest_enemy() -> Enemy:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var nearest: Enemy = null
	var shortest_distance := possession_range + 1.0
	
	print("Looking for enemies, found: ", enemies.size())
	
	for enemy in enemies:
		if enemy is Enemy:
			var distance := global_position.distance_to(enemy.global_position)
			print("Enemy at distance: ", distance, " controlled: ", enemy.is_controlled())
			
			# Can possess any enemy that's not currently controlled
			if not enemy.is_controlled()  and distance < shortest_distance:
				shortest_distance = distance
				nearest = enemy
				print("Found valid enemy at distance: ", shortest_distance)
	
	return nearest

func _is_in_range(enemy: Enemy) -> bool:
	return global_position.distance_to(enemy.global_position) <= possession_range
