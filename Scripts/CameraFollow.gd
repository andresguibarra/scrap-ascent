extends Camera2D

@export var follow_speed: float = 5.0
@export var offset_y: float = -50.0

var target: Node2D

func _process(delta: float) -> void:
	_find_target()
	
	if target and is_instance_valid(target):
		var target_position := Vector2(target.global_position.x, target.global_position.y + offset_y)
		global_position = global_position.lerp(target_position, follow_speed * delta)

func _find_target() -> void:
	# First, look for an Orb (priority)
	var orbs := get_tree().get_nodes_in_group("player")
	for orb in orbs:
		if orb.name == "Orb" and is_instance_valid(orb):
			if target != orb:
				target = orb
				print("Camera following Orb")
			return
	
	# If no Orb, look for a controlled Enemy
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
