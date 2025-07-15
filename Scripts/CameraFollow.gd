extends Camera2D

@export var follow_speed: float = 8.0
@export var offset_y: float = -50.0
@export var possession_zoom: float = 1.9
@export var zoom_speed: float = 3.0  # Reduced from 14.0 for more gradual transitions
@export var zoom_transition_duration: float = 1.0  # Duration for zoom transitions
@export var smooth_threshold: float = 1.5  # Distance threshold for smooth following

var target: Node2D
var base_zoom: Vector2 = Vector2.ONE
var target_zoom: Vector2 = Vector2.ONE
var is_possessing: bool = false
var zoom_multiplier: float = 3.0
var zoom_tween: Tween

func _process(delta: float) -> void:
	_find_target()
	_update_zoom(delta)
	
	if target and is_instance_valid(target):
		var target_position := Vector2(target.global_position.x, target.global_position.y + offset_y)
		var distance_to_target := global_position.distance_to(target_position)
		
		# Use different follow speeds based on distance
		var effective_speed := follow_speed
		if distance_to_target < smooth_threshold:
			# Slower, smoother movement when close to target
			effective_speed = follow_speed * 0.1
		
		# Smooth following with adaptive speed
		global_position = global_position.lerp(target_position, effective_speed * delta)

func _find_target() -> void:
	# Always check for an Orb first (highest priority)
	var orbs := get_tree().get_nodes_in_group("player")
	for orb in orbs:
		if orb.name == "Orb" and is_instance_valid(orb):
			if target != orb:
				_set_new_target(orb, "new Orb")
			return
	
	# If no Orb found, look for a controlled Enemy
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy is Enemy and enemy.is_controlled() and is_instance_valid(enemy):
			if target != enemy:
				_set_new_target(enemy, "controlled Enemy")
			return
	
	# No valid target found
	if target:
		print("Camera lost target")
		target = null

func _set_new_target(new_target: Node2D, target_type: String) -> void:
	target = new_target
	print("Camera following " + target_type)
	
	# If the new target is an Orb, connect to its possession signals
	if new_target.name == "Orb":
		_connect_orb_signals(new_target)

func _ready() -> void:
	# Add camera to the camera group
	add_to_group("camera")
	
	# Store the initial zoom level
	base_zoom = zoom
	target_zoom = base_zoom * zoom_multiplier
	print("Camera: Ready - Base zoom stored")
	_smooth_zoom_transition()
	# Initially follow the Orb if available
	_set_initial_target()

func _update_zoom(delta: float) -> void:
	# Zoom updates are now handled by Tween for smoother transitions
	pass

func _on_possession_started() -> void:
	is_possessing = true
	_smooth_zoom_transition()
	print("Camera: Zooming in for possession")

func _on_possession_ended() -> void:
	is_possessing = false
	_smooth_zoom_transition()
	print("Camera: Zooming out, possession ended")

func _set_initial_target() -> void:
	# Look for an Orb to follow initially
	var orbs := get_tree().get_nodes_in_group("player")
	for orb in orbs:
		if orb.name == "Orb" and is_instance_valid(orb):
			_set_new_target(orb, "initial Orb")
			return

func _connect_orb_signals(orb: Node2D) -> void:
	# Disconnect from previous orb if any connections exist
	if orb.has_signal("possession_started"):
		if orb.possession_started.is_connected(_on_possession_started):
			orb.possession_started.disconnect(_on_possession_started)
		orb.possession_started.connect(_on_possession_started)
		print("Camera: Connected to possession_started signal")
	
	if orb.has_signal("possession_ended"):
		if orb.possession_ended.is_connected(_on_possession_ended):
			orb.possession_ended.disconnect(_on_possession_ended)
		orb.possession_ended.connect(_on_possession_ended)
		print("Camera: Connected to possession_ended signal")

func set_zoom_multiplier(multiplier: float) -> void:
	zoom_multiplier = multiplier
	_smooth_zoom_transition()
	print("Camera: Zoom multiplier set to ", multiplier)

func reset_zoom_multiplier() -> void:
	zoom_multiplier = 3.0
	_smooth_zoom_transition()
	print("Camera: Zoom multiplier reset to 3.0")

func _smooth_zoom_transition() -> void:
	# Calculate new target zoom
	var new_target_zoom: Vector2
	if is_possessing:
		new_target_zoom = base_zoom * possession_zoom * zoom_multiplier
	else:
		new_target_zoom = base_zoom * zoom_multiplier
	
	# Kill existing tween if running
	if zoom_tween:
		zoom_tween.kill()
	
	# Create smooth zoom transition
	zoom_tween = create_tween()
	zoom_tween.set_ease(Tween.EASE_OUT)
	zoom_tween.set_trans(Tween.TRANS_CUBIC)
	zoom_tween.tween_property(self, "zoom", new_target_zoom, zoom_transition_duration)
	
	# Update target_zoom for future reference
	target_zoom = new_target_zoom

func _update_target_zoom() -> void:
	# This method is kept for compatibility but now uses smooth transition
	_smooth_zoom_transition()
