extends Area2D

@export var zoom_multiplier: float = 1.5

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	print("ZoomOutArea2D: Ready with zoom multiplier ", zoom_multiplier)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		print("ZoomOutArea2D: Enemy entered - ", body.name)
		_adjust_camera_zoom()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		print("ZoomOutArea2D: Enemy exited - ", body.name)
		_restore_camera_zoom()

func _adjust_camera_zoom() -> void:
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("set_zoom_multiplier"):
		camera.set_zoom_multiplier(zoom_multiplier)
		print("ZoomOutArea2D: Camera zoom adjusted to ", zoom_multiplier)
	else:
		print("ZoomOutArea2D: Camera not found or method not available")

func _restore_camera_zoom() -> void:
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("reset_zoom_multiplier"):
		camera.reset_zoom_multiplier()
		print("ZoomOutArea2D: Camera zoom restored to normal")
	else:
		print("ZoomOutArea2D: Camera not found or method not available")
