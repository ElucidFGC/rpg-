extends Area2D

@export var SPEED = 300  # Fireball speed
var direction = Vector2.ZERO  # Direction of travel

func _ready():
	get_tree().create_timer(1.0).timeout.connect(queue_free)  # Destroy after 3 sec
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT  # Default direction
	rotation = direction.angle()

func _physics_process(delta):
	# Move the fireball in the given direction
	position += direction.normalized() * SPEED * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):  # Ensure it only affects enemies
		body.take_damage()  # Example function on enemy
		queue_free()
