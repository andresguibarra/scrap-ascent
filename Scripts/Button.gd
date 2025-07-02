extends Node2D

# Signals for connecting to other systems
signal activated
signal deactivated

@export var inactive_color := Color(0.082, 0.129, 0.071, 1.0)  # #2f4829
@export var active_color := Color(0.184, 0.282, 0.161, 1.0)    # #abd9a1

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var light: PointLight2D = $PointLight2D

var is_active: bool = false
var enemies_on_button: int = 0

func _ready() -> void:
	_setup_button()
	_connect_signals()

func _setup_button() -> void:
	if sprite:
		sprite.frame = 0
		sprite.modulate = inactive_color
	
	if area:
		# Configure collision mask to detect enemies (layer 3)
		area.collision_mask = 1 << 2  # Layer 3 (Enemies)
	
	if light:
		# Start with light disabled
		light.enabled = false

func _connect_signals() -> void:
	if area:
		if not area.body_entered.is_connected(_on_body_entered):
			area.body_entered.connect(_on_body_entered)
		if not area.body_exited.is_connected(_on_body_exited):
			area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		enemies_on_button += 1
		if not is_active:
			_activate_button()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		enemies_on_button -= 1
		if enemies_on_button <= 0 and is_active:
			_deactivate_button()

func _activate_button() -> void:
	is_active = true
	if sprite:
		sprite.frame = 1
		sprite.modulate = active_color
	if light:
		light.enabled = true
		light.energy = 1.2
		light.color = active_color
	print("Button activated!")
	activated.emit()

func _deactivate_button() -> void:
	is_active = false
	enemies_on_button = 0  # Reset counter to be safe
	if sprite:
		sprite.frame = 0
		sprite.modulate = inactive_color
	if light:
		light.enabled = false
	print("Button deactivated!")
	deactivated.emit()

func get_is_active() -> bool:
	return is_active
