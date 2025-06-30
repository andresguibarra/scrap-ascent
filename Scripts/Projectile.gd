extends RigidBody2D
class_name Projectile

@export var speed: float = 500.0
@export var damage: float = 10.0

var has_hit: bool = false
var shooter: Node = null  # Reference to who shot this projectile

func _ready() -> void:
	add_to_group("projectiles")
	# Enable contact monitoring for collision detection
	contact_monitor = true
	max_contacts_reported = 10
	
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func launch(direction: Vector2, from_shooter: Node = null) -> void:
	linear_velocity = direction * speed
	shooter = from_shooter

func _on_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node) -> void:
	# Prevent multiple hits
	if has_hit:
		return
		
	has_hit = true
	
	# Apply damage if the body can take damage
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Always destroy projectile on collision
	queue_free()
