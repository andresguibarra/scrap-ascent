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
@export var switch_on_sound: AudioStream
@export var switch_off_sound: AudioStream
@export var audio_max_distance: float = 700.0:
	set(value):
		audio_max_distance = max(50.0, value)  # Minimum 50 pixels
		_update_audio_settings()
@export var audio_volume_db: float = -5.0:
	set(value):
		audio_volume_db = clamp(value, -80.0, 24.0)  # Valid dB range
		_update_audio_settings()

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Node2D/Area2D
@onready var light: PointLight2D = $Node2D/PointLight2D
@onready var node2d: Node2D = $Node2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
var is_active: bool = false
var enemies_on_button: int = 0

func _ready() -> void:
	add_to_group("buttons")
	_setup_button()
	_setup_audio()
	if not Engine.is_editor_hint():
		_connect_signals()

func _process(_delta: float) -> void:
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
	
	if not Engine.is_editor_hint():
		if area:
			# Configure collision detection based on type
			if _is_temporary_button():
				# Temporary buttons detect enemies (layer 3) and weapons (layer 6)
				area.collision_mask = (1 << 2) | (1 << 5)  # Layer 3 (Enemies) + Layer 6 (Weapons)
			else:
				# Permanent buttons (LIGHT_*) detect projectiles only
				area.collision_mask = 1 << 4  # Layer 5 (Projectiles) - adjust layer as needed
	
	if light:
		# Start with light disabled
		light.enabled = false

func _setup_audio() -> void:
	if audio_player:
		# Configure audio range - audible up to specified distance
		audio_player.max_distance = audio_max_distance
		# Set attenuation for natural sound falloff
		audio_player.attenuation = 1.0
		# Set volume level
		audio_player.volume_db = audio_volume_db

func _update_audio_settings() -> void:
	# Update audio settings when variables change (called by setters)
	if audio_player:
		audio_player.max_distance = audio_max_distance
		audio_player.volume_db = audio_volume_db

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
	if _is_temporary_button() and (body.is_in_group("enemies") or body.is_in_group("weapons")):
		# Temporary buttons activated by enemies or weapons
		enemies_on_button += 1
		if not is_active:
			_activate_button()
	elif _is_permanent_button() and body.is_in_group("projectiles"):
		# Permanent buttons activated by projectiles
		if not is_active:
			_activate_permanent_button()

func _on_body_exited(body: Node2D) -> void:
	if _is_temporary_button() and (body.is_in_group("enemies") or body.is_in_group("weapons")):
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
	_play_sound(switch_on_sound)
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
	_play_sound(switch_on_sound)
	print("Permanent button activated!")
	activated.emit()

func _deactivate_button() -> void:
	# Only temporary buttons can be deactivated
	#if not _is_temporary_button():
		#return
		
	is_active = false
	enemies_on_button = 0  # Reset counter to be safe
	if sprite:
		# Set frame based on button type (maintain type when deactivating)
		if type == Type.BUTTON:
			sprite.frame = 0  # Button inactive frame
		elif type == Type.LIGHT_LEFT:
			sprite.frame = 2  # Light left inactive frame
		elif type == Type.LIGHT_RIGHT:
			sprite.frame = 4  # Light right inactive frame
		sprite.modulate = inactive_color
	if light:
		light.enabled = false
	_play_sound(switch_off_sound)
	print("Button deactivated!")
	deactivated.emit()

func get_is_active() -> bool:
	return is_active

func _play_sound(sound: AudioStream) -> void:
	if sound and audio_player:
		audio_player.stream = sound
		audio_player.play()
