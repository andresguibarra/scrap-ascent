extends Camera2D

@export var follow_speed: float = 5.0
@export var offset_y: float = -50.0
@export var possession_zoom: float = 1.9  # Zoom level during possession
@export var zoom_speed: float = 7.0  # Speed of zoom transitions

var target: Node2D
var base_zoom: Vector2 = Vector2.ONE
var target_zoom: Vector2 = Vector2.ONE
var is_possessing: bool = false

func _process(delta: float) -> void:
	_find_target()
	_update_zoom(delta)
	
	if target and is_instance_valid(target):
		var target_position := Vector2(target.global_position.x, target.global_position.y + offset_y)
		global_position = global_position.lerp(target_position, follow_speed * delta)

func _find_target() -> void:
	# Always check for an Orb first (highest priority)
	var orbs := get_tree().get_nodes_in_group("player")
	for orb in orbs:
		if orb.name == "Orb" and is_instance_valid(orb):
			if target != orb:
				target = orb
				print("Camera following new Orb")
				# Connect to possession signals of the new Orb
			return
	
	# If no Orb found, look for a controlled Enemy
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy is Enemy and enemy.is_controlled() and is_instance_valid(enemy):
			if target != enemy:
				target = enemy
				print("Camera following controlled Enemy")
			return
	
	# No valid target found
	if target:
		print("Camera lost target")
		target = null

func _ready() -> void:
	# Store the initial zoom level
	base_zoom = zoom
	target_zoom = base_zoom
	print("Camera: Ready - Base zoom stored")
	
	# Initially follow the Orb if available
	_set_initial_target()

func _update_zoom(delta: float) -> void:
	# Smoothly interpolate to target zoom
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)

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
			target = orb
			print("Camera: Initially following Orb")
			return
