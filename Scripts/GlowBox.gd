@tool
extends StaticBody2D

@export var trigger_node: Node2D
@export var start_active: bool = false
# Colors in hex format converted to Color
@export var inactive_color := Color(0.333, 0.522, 0.306, 1.0)  # 55854e
@export var active_color := Color(0.545, 0.784, 0.510, 1.0)    # 8bc882

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var is_active: bool = false


func _ready() -> void:
	if not Engine.is_editor_hint():
		_set_initial_state()
		_connect_to_trigger()

func _set_initial_state() -> void:
	if start_active:
		_activate()
	else:
		_deactivate()

func _connect_to_trigger() -> void:
	if trigger_node and trigger_node.has_signal("activated"):
		if not trigger_node.activated.is_connected(_on_trigger_activated):
			trigger_node.activated.connect(_on_trigger_activated)
	
	if trigger_node and trigger_node.has_signal("deactivated"):
		if not trigger_node.deactivated.is_connected(_on_trigger_deactivated):
			trigger_node.deactivated.connect(_on_trigger_deactivated)

func _on_trigger_activated() -> void:
	_activate()

func _on_trigger_deactivated() -> void:
	_deactivate()

func _activate() -> void:
	if Engine.is_editor_hint():
		return
		
	is_active = true
	
	# Enable collision by setting it to World layer and enabling the shape
	#collision_layer = 1 << 0  # Layer 1 (World)
	if collision_shape:
		collision_shape.set_deferred("disabled", false)
		#collision_shape.disabled = false
	
	# Set active color and frame
	if sprite:
		sprite.frame = 3
		sprite.modulate = active_color

func _deactivate() -> void:
	if Engine.is_editor_hint():
		return
		
	is_active = false
	
	# Disable collision completely
	#collision_layer = 0  # No collision layer
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
		#collision_shape.disabled = true
	
	# Set inactive color and frame
	if sprite:
		sprite.frame = 2
		sprite.modulate = inactive_color

func get_is_active() -> bool:
	return is_active
