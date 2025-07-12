extends CharacterBody2D

# Signals for camera zoom
signal possession_started
signal possession_ended

@export var speed := 200.0
# @export var possession_range := 100.0 # Increased for testing
@export var attraction_speed := 400.0 # Speed when moving towards enemy for possession
@export var orb_sound: AudioStream
@export var possession_sound: AudioStream
var controlled = true
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Possession state
var is_possessing: bool = false
var target_enemy: Enemy = null

# Light pulsing variables
var base_light_energy: float = 1.0
var pulse_speed: float = 2.0
var pulse_amplitude: float = 0.5
var light_time: float = 0.0

# Particle default values (your preferred settings)
var default_particle_amount: int = 16
var default_velocity_min: float = 2.0
var default_velocity_max: float = 20.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var light: PointLight2D = $PointLight2D
@onready var line_of_sight: RayCast2D = $LineOfSight
@onready var particles: GPUParticles2D = $Particles
@onready var particles_intense: GPUParticles2D = $ParticlesIntense
@onready var posession_area: Area2D = $PosessionArea2D

func _ready() -> void:
	name = "Orb"
	add_to_group("player")
	_play_idle_animation()
	_setup_light_pulsing()
	_setup_line_of_sight()
	_setup_particles()

func _process(delta: float) -> void:
	if is_possessing:
		_handle_possession_movement(delta)
		return
	
	var direction: Vector2 = InputManager.get_movement_input()
	target_enemy = _find_nearest_enemy()
	# _has_clear_line_of_sight(enemy)
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

func _handle_possession_movement(_delta: float) -> void:
	if not target_enemy or not is_instance_valid(target_enemy):
		#print("Orb: Target enemy lost during possession")
		_cancel_possession()
		return
	
	# Check if line of sight is still clear during movement
	if not _has_clear_line_of_sight(target_enemy):
		_cancel_possession()
		return
	
	# Move towards the target enemy with increasing speed as we get closer
	var direction_to_enemy := (target_enemy.global_position - global_position).normalized()
	var distance_to_enemy := global_position.distance_to(target_enemy.global_position)
	
	# Speed up as we get closer for dramatic effect
	var current_speed := attraction_speed
	if distance_to_enemy < 50.0:
		current_speed = attraction_speed * 1.5 # 50% faster when close
	
	velocity = direction_to_enemy * current_speed
	
	# Update animation based on movement direction
	if abs(direction_to_enemy.x) > 0.1:
		_play_movement_animation(direction_to_enemy.x)
	
	# Enhanced light effect during possession
	_update_light_intensity(true)
	
	# Extra intense particle trail during possession
	_set_particle_parameters("possession")
	
	# Check if we're close enough to complete possession
	if distance_to_enemy < 20.0: # Close enough to possess
		# Disable all collisions to pass through everything
		collision_layer = 0
		collision_mask = 0
		
		_complete_possession()
		return
	
	move_and_slide()

# =============================================================================
# LIGHTING EFFECTS
# =============================================================================
func _setup_light_pulsing() -> void:
	if light:
		light.energy = base_light_energy
		#print("Orb: Light initialized with energy: ", light.energy, " and color: ", light.color)
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
		base_light_energy = 2.5 # Brighter when moving
		pulse_amplitude = 0.8 # More intense pulsing
	else:
		base_light_energy = 2.0 # Normal brightness when idle
		pulse_amplitude = 0.5 # Gentle pulsing
	
	# Update particle intensity based on movement
	_update_particle_intensity(is_moving)

func _update_particle_intensity(is_moving: bool) -> void:
	if is_moving:
		_set_particle_parameters("moving")
	else:
		_set_particle_parameters("idle")

func _set_particle_parameters(state: String) -> void:
	if not particles or not particles_intense:
		return
		
	var particle_material = particles.process_material as ParticleProcessMaterial
	var particle_material_intense = particles_intense.process_material as ParticleProcessMaterial
	
	if not particle_material or not particle_material_intense:
		return
	
	match state:
		"idle":
			# Base particles always on, intense particles off
			particles.emitting = true
			particles_intense.emitting = false
			# Reset velocities to default for base particles
			particle_material.initial_velocity_max = default_velocity_max
			particle_material.initial_velocity_min = default_velocity_min
			
		"moving":
			# Both particle systems active
			particles.emitting = true
			particles_intense.emitting = true
			# Boost velocities for movement
			particle_material.initial_velocity_max = default_velocity_max + 5.0
			particle_material.initial_velocity_min = default_velocity_min + 2.0
			particle_material_intense.initial_velocity_max = default_velocity_max + 10.0
			particle_material_intense.initial_velocity_min = default_velocity_min + 5.0
			
		"possession":
			# Both systems with high intensity
			particles.emitting = true
			particles_intense.emitting = true
			particle_material.initial_velocity_max = default_velocity_max + 8.0
			particle_material.initial_velocity_min = default_velocity_min + 4.0
			particle_material_intense.initial_velocity_max = default_velocity_max + 15.0
			particle_material_intense.initial_velocity_min = default_velocity_min + 8.0
			
		"flash":
			# Maximum intensity for flash effect
			particles.emitting = true
			particles_intense.emitting = true
			particle_material.initial_velocity_max = default_velocity_max + 10.0
			particle_material.initial_velocity_min = default_velocity_min + 5.0
			particle_material_intense.initial_velocity_max = default_velocity_max + 20.0
			particle_material_intense.initial_velocity_min = default_velocity_min + 10.0

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
	if target_enemy:
		AudioManager.play_sound(possession_sound, -5)
		print("Orb: Starting possession sequence towards enemy")
		is_possessing = true
		controlled = false # Stop responding to normal input
		_flash_light_on_possession()
		possession_started.emit()
	else:
		print("Orb: No valid enemy found for possession")
		AudioManager.play_sound(orb_sound)

func _flash_light_on_possession() -> void:
	if light:
		# Enhanced light effect during possession
		light.energy = 4.0
		light.range_item_cull_mask = 4 # Increase range momentarily
		base_light_energy = 3.0 # Keep it bright during possession
		pulse_amplitude = 1.0 # Intense pulsing during possession
	
	# Enhanced particle effect during possession
	_set_particle_parameters("flash")

func _find_nearest_enemy() -> Enemy:
	var enemies := posession_area.get_overlapping_bodies().filter(func(body: Node2D) -> bool:
		return body.is_in_group("enemies") and not body.is_controlled())
	var nearest: Enemy = null
	var shortest_distance := 100000.0
	
	for enemy in enemies:
		var distance := global_position.distance_to(enemy.global_position)
		# Can possess any enemy that's not currently controlled and is in range
		if distance < shortest_distance:
			# Check if there's a clear line of sight to the enemy
			if _has_clear_line_of_sight(enemy):
				shortest_distance = distance
				nearest = enemy
	
	return nearest

func _cancel_possession() -> void:
	print("Orb: Possession cancelled")
	is_possessing = false
	target_enemy = null
	controlled = true
	_reset_particle_effects()
	possession_ended.emit()

func _reset_particle_effects() -> void:
	_set_particle_parameters("idle")

func _complete_possession() -> void:
	print("Orb: Possession completed")
	if target_enemy:
		_flash_light_on_possession()
		target_enemy.possess()
		get_tree().create_timer(0.2).timeout.connect(func(): 
			AudioManager.call_deferred("stop"))
	
	possession_ended.emit()
	
	#get_tree().create_timer(1.0).timeout
	
	queue_free()

func _setup_line_of_sight() -> void:
	if line_of_sight:
		line_of_sight.enabled = true
		line_of_sight.collision_mask = 5 # Collide with world (1) and enemy (4) layers
	else:
		print("Orb: Warning - LineOfSight RayCast2D not found!")

func _setup_particles() -> void:
	if particles and particles_intense:
		# Base particles always emitting
		particles.emitting = true
		particles.amount = default_particle_amount
		
		# Intense particles start disabled
		particles_intense.emitting = false
		particles_intense.amount = 20 # Higher amount for intense effects
		
		print("Orb: Dual particle system initialized")
	else:
		print("Orb: Warning - Particle nodes not found!")

func _has_clear_line_of_sight(enemy: Enemy) -> bool:
	if not line_of_sight or not enemy:
		return false
	
	# Set raycast target to the enemy's position
	var direction_to_enemy := enemy.global_position - global_position
	line_of_sight.target_position = direction_to_enemy
	
	# Force update the raycast
	line_of_sight.force_raycast_update()
	
	# If the raycast is colliding, check what we're hitting
	if line_of_sight.is_colliding():
		var collider = line_of_sight.get_collider()
		
		# If we hit the target enemy or any enemy, that's acceptable
		if collider == enemy or collider is Enemy:
			return true
		
		# If we hit something else (walls, platforms), there's an obstacle
		return false
	
	# If not colliding with anything, there's a clear path
	return true
