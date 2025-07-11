extends RigidBody2D
class_name Weapon

@export var throw_force: float = 350
@export var attract_speed: float = 900.0
@export var shoot_cooldown: float = 0.3
@export var knockback_force: float = 120
@export var gun_get_sound: AudioStream
@export var shoot_sound_1: AudioStream
@export var shoot_sound_2: AudioStream
@export var throw_sound: AudioStream

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
	freeze = true
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
		# Clear any existing horizontal velocity to ensure consistent knockback
		linear_velocity.x = 0
		# Apply fresh knockback with additional force to overcome friction
		linear_velocity += knockback_direction * knockback_force
		
		# Add a small upward component to help the weapon move over small obstacles
		if abs(linear_velocity.y) < 50:  # Only if not already moving vertically
			linear_velocity.y -= 50  # Small upward impulse
		
		print("Weapon: Knockback applied - direction: ", knockback_direction, " velocity: ", linear_velocity)

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
	else:
		var holder_sprite = holder.sprite
		if holder_sprite:
			facing_right = not holder_sprite.flip_h

func _update_flip() -> void:
	sprite.flip_h = not facing_right
	shoot_point.position.x = -2 if facing_right else 2

func _update_position_relative_to_holder() -> void:
	position = Vector2(12 if facing_right else -12, 0)

# =============================================================================
# WEAPON DROPPING AND PICKUP
# =============================================================================
func drop(throw_direction: Vector2 = Vector2.ZERO) -> void:
	if not is_held:
		return
	
	var current_global_pos := global_position
	
	if not _reparent_to_scene(current_global_pos):
		return
	
	_apply_throw_physics(throw_direction)
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

func _apply_throw_physics(throw_direction: Vector2) -> void:
	if throw_direction != Vector2.ZERO:
		linear_velocity = throw_direction * throw_force
	else:
		_apply_default_throw()

func _apply_default_throw() -> void:
	var angle_deg := 60.0 # el ángulo que quieras
	var dir := 1 if facing_right else -1

	# Pasas de grados a radianes y obtienes el vector (cos θ, sen θ)
	var throw_angle := Vector2(
		cos(deg_to_rad(angle_deg)) * dir,
		-sin(deg_to_rad(angle_deg))            # y negativo porque “-y” es arriba
	).normalized()
	var throw_velocity := throw_angle * throw_force
	
	_add_holder_momentum(throw_velocity)
	linear_velocity = throw_velocity

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
	linear_velocity = Vector2.ZERO
	freeze = true
	collision_layer = 0
	collision_mask = 0
	
	_play_gun_get_sound()
	_update_facing_direction()
	_update_position_relative_to_holder()
	_apply_holder_color_modulation()

func _configure_for_dropped_state() -> void:
	is_held = false
	is_being_attracted = false
	freeze = false
	collision_layer = 32
	collision_mask = 1
	
	# Start pickup cooldown when dropping
	pickup_cooldown_timer = pickup_cooldown
	holder_has_left_area = false  # Reset state when dropping

func _configure_for_attraction() -> void:
	collision_layer = 0
	collision_mask = 0
	freeze = true

# =============================================================================
# AUTO SETUP
# =============================================================================
func _auto_setup_holder() -> void:
	var parent_node := get_parent()
	if not parent_node or not parent_node.has_method("is_controlled"):
		return
	
	holder = parent_node
	is_held = true
	
	# Apply holder color modulation during auto-setup
	_apply_holder_color_modulation()
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
		print("Weapon: Holder entered pickup area")

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
# HOLDER COLOR MODULATION
# =============================================================================
func _apply_holder_color_modulation() -> void:
	if not holder or not sprite:
		return
	
	var holder_color := _get_holder_color()
	if holder_color == Color.WHITE:
		return  # No modulation needed
	
	# Apply a light modulation (mix with white for subtle effect)
	var modulation_strength := 0.3  # 30% holder color, 70% original
	var modulated_color := Color.WHITE.lerp(holder_color, modulation_strength)
	sprite.modulate = modulated_color
	
	print("Weapon: Applied holder color modulation - ", modulated_color)

func _reset_weapon_color_modulation() -> void:
	if sprite:
		sprite.modulate = Color.WHITE
		print("Weapon: Reset weapon color modulation")

func _get_holder_color() -> Color:
	if not holder:
		return Color.WHITE
	
	# For Enemy holders, get their tier color
	if holder.has_method("get_tier_color"):
		return holder.get_tier_color()
	
	# Default to white (no modulation)
	return Color.WHITE

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
