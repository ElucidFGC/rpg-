extends Area2D

@export var SPEED = 300  # Fireball speed
var direction = Vector2.ZERO  # Direction of travel

func _ready():
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT  # Default direction if not set
	rotation = direction.angle()  # Rotate sprite to match direction

func _physics_process(delta):
	# Move the fireball in the given direction
	position += direction.normalized() * SPEED * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()  # Remove fireball when it exits the screen

func _on_body_entered(body):
	if body.has_method("player_damage"):  # Ensure it only affects enemies
		body.player_damage()  # Example function on enemy
		queue_free()
