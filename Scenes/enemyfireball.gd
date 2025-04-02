extends Area2D

@export var SPEED = 300  # Fireball speed
var direction = Vector2.ZERO  # Direction of travel

func _ready():
	get_tree().create_timer(1.0).timeout.connect(queue_free)  # Destroy after 3 sec
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT  # Default direction if not set
	rotation = direction.angle()  # Rotate sprite to match direction

func _physics_process(delta):
	# Move fireball
	position += direction.normalized() * SPEED * delta

	# Get the camera node
	var camera = get_viewport().get_camera_2d()
	if camera:
		var screen_rect = Rect2(camera.global_position - camera.get_viewport_rect().size / 2, camera.get_viewport_rect().size)
		
		# If fireball is out of bounds, delete it
		if not screen_rect.has_point(global_position):
			queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()  # Remove fireball when it exits the screen

func _on_body_entered(body):
	if body.has_method("player_damage"):  # Ensure it only affects enemies
		body.player_damage()  # Example function on enemy
		queue_free()
