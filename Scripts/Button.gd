@tool
extends Node2D

# Signals for connecting to other systems
signal activated
signal deactivated
enum Type { BUTTON, LIGHT_RIGHT, LIGHT_LEFT }
@export var inactive_color := Color(0.082, 0.129, 0.071, 1.0)  # #2f4829
@export var active_color := Color(0.184, 0.282, 0.161, 1.0)    # #abd9a1
@export var type = Type.BUTTON:
	set(new_type):
		type = new_type

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Node2D/Area2D
@onready var light: PointLight2D = $Node2D/PointLight2D
@onready var node2d: Node2D = $Node2D
var is_active: bool = false
var enemies_on_button: int = 0

func _ready() -> void:
	_setup_button()
	if not Engine.is_editor_hint():
		_connect_signals()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_setup_button()

func _setup_button() -> void:
	if sprite:
		if type == Type.BUTTON:
			sprite.frame = 0
			node2d.rotation = 0
		elif type == Type.LIGHT_LEFT:
			sprite.frame = 2
			node2d.rotation = deg_to_rad(90)
		elif type == Type.LIGHT_RIGHT:
			sprite.frame = 4
			node2d.rotation = deg_to_rad(-90)
		sprite.modulate = inactive_color
	
	if area:
		# Configure collision detection based on type
		if _is_temporary_button():
			# Temporary buttons (BUTTON) detect enemies (layer 3)
			area.collision_mask = 1 << 2  # Layer 3 (Enemies)
		else:
			# Permanent buttons (LIGHT_*) detect projectiles only
			area.collision_mask = 1 << 4  # Layer 5 (Projectiles) - adjust layer as needed
	
	if light:
		# Start with light disabled
		light.enabled = false

func _connect_signals() -> void:
	if area:
		if not area.body_entered.is_connected(_on_body_entered):
			area.body_entered.connect(_on_body_entered)
		if not area.body_exited.is_connected(_on_body_exited):
			area.body_exited.connect(_on_body_exited)

func _is_temporary_button() -> bool:
	# Temporary buttons are pressure-sensitive (activate/deactivate)
	return type == Type.BUTTON

func _is_permanent_button() -> bool:
	# Permanent buttons stay activated once triggered
	return type == Type.LIGHT_LEFT or type == Type.LIGHT_RIGHT

func _on_body_entered(body: Node2D) -> void:
	if _is_temporary_button() and body.is_in_group("enemies"):
		# Temporary buttons activated by enemies
		enemies_on_button += 1
		if not is_active:
			_activate_button()
	elif _is_permanent_button() and body.is_in_group("projectiles"):
		# Permanent buttons activated by projectiles
		if not is_active:
			_activate_permanent_button()

func _on_body_exited(body: Node2D) -> void:
	if _is_temporary_button() and body.is_in_group("enemies"):
		# Only temporary buttons can be deactivated
		enemies_on_button -= 1
		if enemies_on_button <= 0 and is_active:
			_deactivate_button()
	# Permanent buttons don't deactivate when projectiles leave

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

func _activate_permanent_button() -> void:
	is_active = true
	if sprite:
		# Permanent buttons use different frames when activated
		if type == Type.LIGHT_LEFT:
			sprite.frame = 2  # Activated light left frame
		elif type == Type.LIGHT_RIGHT:
			sprite.frame = 4  # Activated light right frame
		sprite.modulate = active_color
	if light:
		light.enabled = true
		light.energy = 1.2
		light.color = active_color
	print("Permanent button activated!")
	activated.emit()

func _deactivate_button() -> void:
	# Only temporary buttons can be deactivated
	if not _is_temporary_button():
		return
		
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
