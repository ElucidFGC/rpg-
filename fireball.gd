extends Area2D

var SPEED = 300
var direction = Vector2.RIGHT  # Default direction if not set

func _physics_process(delta):
	position += direction.normalized() * SPEED * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
