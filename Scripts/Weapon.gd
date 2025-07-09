extends CharacterBody2D
class_name Weapon

@export var throw_force: float = 320
@export var attract_speed: float = 900.0
@export var shoot_cooldown: float = 0.3
@export var knockback_force: float = 140
@export var gun_get_sound: AudioStream
@export var shoot_sound_1: AudioStream
@export var shoot_sound_2: AudioStream
@export var throw_sound: AudioStream

# Realistic bounce parameters
@export var wall_bounce_factor: float = 0.7  # Tennis ball-like bounce off walls
@export var floor_bounce_factor: float = 0.02  # Almost no bounce on floor
@export var gravity: float = 980.0

var is_held: bool = false
var facing_right: bool = true
var is_being_attracted: bool = false
var shoot_timer: float = 0.0

# Auto-pickup system
var holder_in_area: bool = false
var holder_has_left_area: bool = false
var pickup_cooldown_timer: float = 0.0
@export var pickup_cooldown: float = 1.0  # Seconds to wait after dropping before allowing auto-pickup

@onready var holder: Node2D
@onready var shoot_point: Marker2D = $ShootPoint
@onready var sprite: Sprite2D = $Sprite2D
@onready var pickup_area: Area2D = $PickupArea
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

# =============================================================================
# LIFECYCLE
# =============================================================================
func _ready() -> void:
	add_to_group("weapons")
	_update_flip()
	call_deferred("_auto_setup_holder")
	call_deferred("_setup_pickup_area")

func _physics_process(delta: float) -> void:
	_update_shoot_timer(delta)
	_update_pickup_cooldown(delta)
	_handle_weapon_state()
	
	# Handle physics when not held
	if not is_held:
		_handle_weapon_physics(delta)

# =============================================================================
# WEAPON PHYSICS (SIMPLE)
# =============================================================================
func _handle_weapon_physics(delta: float) -> void:
	if is_being_attracted and holder:
		_handle_attraction_movement()
		return
	
	# Apply gravity
	velocity.y += gravity * delta
	
	# Use move_and_collide for direct control
	var collision := move_and_collide(velocity * delta)
	
	if collision:
		var normal := collision.get_normal()
		
		# Wall bounce (only when moving forward)
		if abs(normal.x) > 0.5:  # Hitting a vertical wall
			var moving_forward := (facing_right and velocity.x > 0) or (not facing_right and velocity.x < 0)
			if moving_forward:
				velocity.x = -velocity.x * wall_bounce_factor
				print("WALL BOUNCE! new velocity.x: ", velocity.x)
			else:
				velocity.x = 0  # Stop when hitting wall backward
				print("WALL STOP! (backward hit)")
		
		# Floor/ceiling bounce
		if abs(normal.y) > 0.5:  # Hitting horizontal surface
			if velocity.y > 0:  # Hitting floor
				velocity.y = -velocity.y * floor_bounce_factor
				# Strong floor friction
				velocity.x *= 0.5
				print("FLOOR HIT! Applied friction, velocity.x now: ", velocity.x)
			else:  # Hitting ceiling
				velocity.y = -velocity.y * wall_bounce_factor
	
	# Additional friction when moving slowly
	if abs(velocity.x) < 30.0 and abs(velocity.y) < 20.0:
		velocity.x *= 0.8

# =============================================================================
# STATE MANAGEMENT
# =============================================================================
func _update_shoot_timer(delta: float) -> void:
	if shoot_timer > 0.0:
		shoot_timer -= delta

func _update_pickup_cooldown(delta: float) -> void:
	if pickup_cooldown_timer > 0.0:
		pickup_cooldown_timer -= delta

func _handle_weapon_state() -> void:
	if not is_held:
		_handle_dropped_state()
	else:
		_handle_held_state()

func _handle_dropped_state() -> void:
	# Handle input for shooting when weapon is dropped
	if holder and holder.is_controlled():
		_handle_input()
	
	if is_being_attracted and holder:
		_handle_attraction_movement()
	
	# Check for automatic pickup when holder re-enters area
	_check_for_auto_pickup()

func _handle_held_state() -> void:
	if holder:
		_sync_with_holder()
		if holder.is_controlled():
			_handle_input()

# =============================================================================
# INPUT HANDLING
# =============================================================================
func _handle_input() -> void:
	if InputManager.is_shoot_just_pressed():
		shoot()
	
	if InputManager.is_weapon_toggle_just_pressed():
		if is_held:
			drop()
		else: 
			return_to_holder()

# =============================================================================
# SHOOTING SYSTEM
# =============================================================================
func shoot() -> bool:
	if shoot_timer > 0.0:
		return false
	
	var projectile := _create_projectile()
	if not projectile:
		return false
	
	_launch_projectile(projectile)
	_apply_recoil_if_needed()
	_play_random_shoot_sound()
	
	shoot_timer = shoot_cooldown
	return true

func _create_projectile() -> Projectile:
	var projectile_scene := preload("res://Scenes/Projectile.tscn")
	var projectile := projectile_scene.instantiate()
	
	var tree := get_tree()
	if tree and tree.current_scene:
		tree.current_scene.add_child(projectile)
		return projectile
	else:
		print("Weapon: Cannot shoot - no scene tree available")
		return null

func _launch_projectile(projectile: Projectile) -> void:
	projectile.global_position = shoot_point.global_position
	var shoot_direction := Vector2(1 if facing_right else -1, 0)
	projectile.launch(shoot_direction, holder, is_held)

func _apply_recoil_if_needed() -> void:
	if not is_held:
		var knockback_direction := Vector2(-1 if facing_right else 1, 0)
		
		# Check if there's a wall DIRECTLY touching the weapon
		var space_state := get_world_2d().direct_space_state
		var query := PhysicsRayQueryParameters2D.create(
			global_position,
			global_position + knockback_direction * 15  # 15 pixels to detect direct contact
		)
		query.collision_mask = collision_mask
		query.exclude = [self]  # Exclude the weapon itself
		var wall_touching := space_state.intersect_ray(query)
		
		if wall_touching:
			# Wall directly touching - only jump upward
			velocity.x = 0
			velocity.y = -180
		else:
			# No wall touching - normal knockback
			velocity.x = knockback_direction.x * knockback_force
			velocity.y = -140

# =============================================================================
# WEAPON POSITIONING AND DIRECTION
# =============================================================================
func _sync_with_holder() -> void:
	if not holder:
		return
	
	var old_facing_right := facing_right
	_update_facing_direction()
	
	if old_facing_right != facing_right:
		_update_flip()
		_update_position_relative_to_holder()

func _update_facing_direction() -> void:
	if holder.has_method("get_facing_direction"):
		var holder_direction: float = holder.get_facing_direction()
		facing_right = holder_direction > 0

func _update_flip() -> void:
	sprite.flip_h = not facing_right
	shoot_point.position.x = -2 if facing_right else 2

func _update_position_relative_to_holder() -> void:
	position = Vector2(12 if facing_right else -12, 0)

# =============================================================================
# WEAPON DROPPING AND PICKUP
# =============================================================================
func drop() -> void:
	if not is_held:
		return
	
	var current_global_pos := global_position
	
	if not _reparent_to_scene(current_global_pos):
		return
	
	_apply_default_throw()
	_configure_for_dropped_state()
	_play_throw_sound()

func _reparent_to_scene(restore_position: Vector2) -> bool:
	if not holder or get_parent() != holder:
		return false
	
	var tree := get_tree()
	holder.remove_child(self)
	
	if tree and tree.current_scene:
		tree.current_scene.add_child(self)
		global_position = restore_position
		return true
	else:
		print("Weapon: Cannot drop - no scene tree available")
		holder.add_child(self)
		is_held = true
		return false

func _apply_default_throw() -> void:
	var angle_deg := 60.0
	var dir := 1 if facing_right else -1

	var throw_angle := Vector2(
		cos(deg_to_rad(angle_deg)) * dir,
		-sin(deg_to_rad(angle_deg))
	).normalized()
	var throw_velocity := throw_angle * throw_force
	
	print("THROW DEBUG: facing_right=", facing_right, " dir=", dir)
	print("THROW DEBUG: throw_angle=", throw_angle)
	print("THROW DEBUG: throw_velocity=", throw_velocity)
	
	_add_holder_momentum(throw_velocity)
	velocity = throw_velocity
	
	print("THROW DEBUG: final velocity=", velocity)

func _add_holder_momentum(throw_velocity: Vector2) -> void:
	if not holder or not holder is CharacterBody2D:
		return
	
	var holder_body := holder as CharacterBody2D
	var holder_velocity: Vector2 = holder_body.velocity
	
	var moving_same_direction := (
		(facing_right and holder_velocity.x > 0) or 
		(not facing_right and holder_velocity.x < 0)
	)
	if moving_same_direction:
		throw_velocity.x += holder_velocity.x

# =============================================================================
# WEAPON ATTRACTION AND PICKUP
# =============================================================================
func return_to_holder() -> void:
	if holder:
		is_being_attracted = true

func _handle_attraction_movement() -> void:
	if not holder:
		is_being_attracted = false
		return
	
	_configure_for_attraction()
	_move_towards_holder()
	_check_pickup_distance()

func _move_towards_holder() -> void:
	var direction := (holder.global_position - global_position).normalized()
	global_position += direction * attract_speed * get_physics_process_delta_time()

func _check_pickup_distance() -> void:
	var distance := global_position.distance_to(holder.global_position)
	if distance < 30.0:
		_attach_to_holder()

func _attach_to_holder() -> void:
	if not holder:
		return
	
	_reparent_to_holder()
	_configure_for_held_state()
	_update_flip()

func _reparent_to_holder() -> void:
	if get_parent() != holder:
		get_parent().remove_child(self)
		holder.add_child(self)

# =============================================================================
# WEAPON CONFIGURATION STATES
# =============================================================================
func _configure_for_held_state() -> void:
	is_held = true
	is_being_attracted = false
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	
	_play_gun_get_sound()
	_update_facing_direction()
	_update_position_relative_to_holder()

func _configure_for_dropped_state() -> void:
	is_held = false
	is_being_attracted = false
	collision_layer = 32  # Layer 6 (Weapons)
	collision_mask = 1    # Layer 1 (World) - should be enough for walls
	
	# Start pickup cooldown when dropping
	pickup_cooldown_timer = pickup_cooldown
	holder_has_left_area = false  # Reset state when dropping

func _configure_for_attraction() -> void:
	collision_layer = 0
	collision_mask = 0

# =============================================================================
# AUTO SETUP
# =============================================================================
func _auto_setup_holder() -> void:
	var parent_node := get_parent()
	if not parent_node or not parent_node.has_method("is_controlled"):
		return
	
	holder = parent_node
	is_held = true
	
	_update_flip()

# =============================================================================
# AUTO-PICKUP SYSTEM
# =============================================================================
func _setup_pickup_area() -> void:
	if not pickup_area:
		print("Weapon: Warning - PickupArea not found!")
		return
	
	# Connect signals for area detection
	if not pickup_area.area_entered.is_connected(_on_pickup_area_entered):
		pickup_area.area_entered.connect(_on_pickup_area_entered)
	if not pickup_area.body_entered.is_connected(_on_pickup_body_entered):
		pickup_area.body_entered.connect(_on_pickup_body_entered)
	if not pickup_area.body_exited.is_connected(_on_pickup_body_exited):
		pickup_area.body_exited.connect(_on_pickup_body_exited)
	
	print("Weapon: Auto-pickup area setup complete")

func _on_pickup_area_entered(_area: Area2D) -> void:
	# We're only interested in body detection for this feature
	pass

func _on_pickup_body_entered(body: Node2D) -> void:
	if body == holder:
		holder_in_area = true

func _on_pickup_body_exited(body: Node2D) -> void:
	if body == holder:
		holder_in_area = false
		holder_has_left_area = true
		print("Weapon: Holder left pickup area")

func _check_for_auto_pickup() -> void:
	# Only auto-pickup if:
	# 1. Weapon is not held
	# 2. Holder exists and is in area
	# 3. Holder has previously left the area (to avoid immediate pickup after drop)
	# 4. Pickup cooldown has expired
	# 5. Weapon is not already being attracted
	if not is_held and holder and holder_in_area and holder_has_left_area and pickup_cooldown_timer <= 0.0 and not is_being_attracted:
		return_to_holder()

# =============================================================================
# AUDIO SYSTEM
# =============================================================================
func _play_gun_get_sound() -> void:
	if gun_get_sound and audio_player:
		audio_player.stream = gun_get_sound
		audio_player.play()

func _play_random_shoot_sound() -> void:
	if not audio_player:
		return
	
	var sounds_available: Array[AudioStream] = []
	
	# Collect available shoot sounds
	if shoot_sound_1:
		sounds_available.append(shoot_sound_1)
	if shoot_sound_2:
		sounds_available.append(shoot_sound_2)
	
	# Play random sound if any are available
	if sounds_available.size() > 0:
		var random_index = randi() % sounds_available.size()
		var selected_sound = sounds_available[random_index]
		audio_player.stream = selected_sound
		audio_player.play()

func _play_throw_sound() -> void:
	if throw_sound and audio_player:
		audio_player.stream = throw_sound
		audio_player.play()
