@tool
extends StaticBody2D

@export var trigger_node: Node2D
@export var countdown_duration: float = 3.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var light: PointLight2D = $PointLight2D

var is_counting_down: bool = false
var countdown_timer: float = 0.0

# Colors for countdown effect
var countdown_light_color := Color(1.0, 0.8, 0.3, 1.0)  # Warm yellow/orange

func _ready() -> void:
	if not Engine.is_editor_hint():
		_set_initial_state()
		_connect_to_trigger()

func _process(delta: float) -> void:
	if not Engine.is_editor_hint() and is_counting_down:
		_update_countdown(delta)

func _set_initial_state() -> void:
	is_counting_down = false
	countdown_timer = 0.0
	
	# Set initial idle state
	if animated_sprite:
		animated_sprite.play("Off")
	
	# Light starts disabled
	if light:
		light.enabled = false

func _connect_to_trigger() -> void:
	if trigger_node and trigger_node.has_signal("activated"):
		if not trigger_node.activated.is_connected(_on_trigger_activated):
			trigger_node.activated.connect(_on_trigger_activated)

func _on_trigger_activated() -> void:
	_start_countdown()

func _start_countdown() -> void:
	if Engine.is_editor_hint() or is_counting_down:
		return
	
	is_counting_down = true
	countdown_timer = countdown_duration
	
	# Start countdown animation (play once, don't loop)
	if animated_sprite:
		animated_sprite.play("Countdown")
		animated_sprite.pause()  # Pause to control manually
	
	# Activate countdown light
	if light:
		light.enabled = true
		light.energy = 1.5
		light.color = countdown_light_color
		# Add subtle pulsing effect
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(light, "energy", 2.0, 0.5)
		tween.tween_property(light, "energy", 1.0, 0.5)

func _update_countdown(delta: float) -> void:
	countdown_timer -= delta
	
	# Update animation progress based on timer
	if animated_sprite and animated_sprite.sprite_frames:
		var progress = 1.0 - (countdown_timer / countdown_duration)
		var total_frames = animated_sprite.sprite_frames.get_frame_count("Countdown")
		if total_frames > 0:
			var target_frame = int(progress * total_frames)
			target_frame = min(target_frame, total_frames - 1)
			animated_sprite.frame = target_frame
	
	# Finish countdown when timer reaches zero
	if countdown_timer <= 0.0:
		_finish_countdown()

func _finish_countdown() -> void:
	is_counting_down = false
	countdown_timer = 0.0
	
	# Return to off state
	if animated_sprite:
		animated_sprite.play("Off")
	
	# Disable light
	if light:
		light.enabled = false
	
	# Deactivate the trigger button
	if trigger_node and trigger_node.has_method("_deactivate_button"):
		trigger_node._deactivate_button()
	elif trigger_node and trigger_node.has_signal("deactivated"):
		# If the button doesn't have the method, emit deactivated signal
		trigger_node.deactivated.emit()

func get_is_counting_down() -> bool:
	return is_counting_down

func get_remaining_time() -> float:
	return max(0.0, countdown_timer)
