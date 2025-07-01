extends CharacterBody2D

@export var speed := 200.0
@export var possession_range := 100.0  # Increased for testing
var controlled = true
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Light pulsing variables
var base_light_energy: float = 1.0
var pulse_speed: float = 2.0
var pulse_amplitude: float = 0.5
var light_time: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var light: PointLight2D = $PointLight2D

func _ready() -> void:
	name = "Orb"
	add_to_group("player")
	_play_idle_animation()
	_setup_light_pulsing()

func _process(delta: float) -> void:
	var direction: Vector2 = InputManager.get_movement_input()
	
	# Orb horizontal movement
	if direction.x != 0:
		velocity.x = direction.x * speed
		_play_movement_animation(direction.x)
		_update_light_intensity(true)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 2.0)
		_play_idle_animation()
		_update_light_intensity(false)
	
	# Apply gravity always
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	move_and_slide()
	_update_light_pulsing(delta)

# =============================================================================
# LIGHTING EFFECTS
# =============================================================================
func _setup_light_pulsing() -> void:
	if light:
		light.energy = base_light_energy
		print("Orb: Light initialized with energy: ", light.energy, " and color: ", light.color)
	else:
		print("Orb: Warning - PointLight2D not found!")

func _update_light_pulsing(delta: float) -> void:
	if not light:
		return
	
	light_time += delta
	var pulse_factor := sin(light_time * pulse_speed) * pulse_amplitude
	light.energy = base_light_energy + pulse_factor

func _update_light_intensity(is_moving: bool) -> void:
	if not light:
		return
	
	if is_moving:
		base_light_energy = 2.5  # Brighter when moving
		pulse_amplitude = 0.8    # More intense pulsing
	else:
		base_light_energy = 2.0  # Normal brightness when idle
		pulse_amplitude = 0.5    # Gentle pulsing

# =============================================================================
# ANIMATION MANAGEMENT
# =============================================================================
func _play_idle_animation() -> void:
	if animated_sprite.animation != "Idle":
		animated_sprite.play("Idle")

func _play_movement_animation(direction_x: float) -> void:
	var target_animation := "MoveRight" if direction_x > 0 else "MoveLeft"
	if animated_sprite.animation != target_animation:
		animated_sprite.play(target_animation)

# =============================================================================
# INPUT HANDLING
# =============================================================================
func _unhandled_input(_event: InputEvent) -> void:
	if controlled and InputManager.is_possess_just_pressed():
		print("Orb: attempting possession")
		_attempt_possession()
		get_viewport().set_input_as_handled()

func _attempt_possession() -> void:
	var enemy := _find_nearest_enemy()
	if enemy:
		_flash_light_on_possession()
		controlled = false  # Reset orb control state
		enemy.posses()
		queue_free()

func _flash_light_on_possession() -> void:
	if light:
		# Brief flash effect before possession
		light.energy = 3.0
		light.range_item_cull_mask = 4  # Increase range momentarily

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
