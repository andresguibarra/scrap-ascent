extends Camera2D

@export var follow_speed: float = 8.0
@export var offset_y: float = -50.0
@export var possession_zoom: float = 1.3
@export var zoom_speed: float = 14.0
@export var smooth_threshold: float = 1.5  # Distance threshold for smooth following

var target: Node2D
var base_zoom: Vector2 = Vector2.ONE
var target_zoom: Vector2 = Vector2.ONE
var is_possessing: bool = false

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
	# Store the initial zoom level
	base_zoom = zoom
	target_zoom = base_zoom
	print("Camera: Ready - Base zoom stored")
	
	# Initially follow the Orb if available
	_set_initial_target()

func _update_zoom(delta: float) -> void:
	# Smoothly interpolate to target zoom with better precision
	var zoom_difference := target_zoom - zoom
	if zoom_difference.length() > 0.001:  # Only update if there's a meaningful difference
		zoom = zoom.lerp(target_zoom, zoom_speed * delta)
	else:
		zoom = target_zoom  # Snap to target when very close

func _on_possession_started() -> void:
	is_possessing = true
	target_zoom = base_zoom * possession_zoom
	print("Camera: Zooming in for possession")

func _on_possession_ended() -> void:
	is_possessing = false
	target_zoom = base_zoom
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
