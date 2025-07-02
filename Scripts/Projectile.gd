extends RigidBody2D
class_name Projectile

@export var speed: float = 500.0
@export var damage: float = 10.0
@export var impact_duration: float = 0.1  # Duration to show impact frames

var has_hit: bool = false
var shooter: Node = null  # Reference to who shot this projectile

@onready var sprite: Sprite2D = $Sprite2D
@onready var impact_timer: Timer = Timer.new()

func _ready() -> void:
	add_to_group("projectiles")
	# Enable contact monitoring for collision detection
	contact_monitor = true
	max_contacts_reported = 10
	
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)
	
	# Setup impact timer
	add_child(impact_timer)
	impact_timer.wait_time = impact_duration
	impact_timer.one_shot = true
	impact_timer.timeout.connect(_on_impact_finished)
	
	# Set initial frame
	if sprite:
		sprite.frame = 0

func launch(direction: Vector2, from_shooter: Node = null) -> void:
	linear_velocity = direction * speed
	shooter = from_shooter
	
	# Set sprite direction based on movement direction
	if sprite and direction.x != 0:
		# Sprite frame 0 faces left by default, so flip when going right
		sprite.flip_h = direction.x > 0

func _on_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node) -> void:
	# Prevent multiple hits
	if has_hit:
		return
		
	has_hit = true
	
	# Stop the projectile movement
	freeze = true
	
	# Apply damage if the body can take damage
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Show impact animation
	_show_impact_frames()

func _show_impact_frames() -> void:
	if not sprite:
		queue_free()
		return
	
	# Show frame 3 first (impact frame)
	sprite.frame = 2
	
	# Create a quick tween to cycle through impact frames
	var tween = create_tween()
	tween.tween_callback(_set_frame.bind(3)).set_delay(impact_duration * 0.5)
	tween.tween_callback(queue_free).set_delay(impact_duration * 0.5)

func _set_frame(frame_number: int) -> void:
	if sprite:
		sprite.frame = frame_number

func _on_impact_finished() -> void:
	queue_free()
