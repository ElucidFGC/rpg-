extends Area2D

@export var spawn_offset = Vector2(0, 0)  # Adjust this value to control where the fireball spawns relative to the enemy
@export var velocity = Vector2.ZERO  # No velocity for movement

func _ready():
	# Set the initial position of the fireball to spawn in front of the enemy
	position = get_parent().position + spawn_offset.rotated(get_parent().rotation)
	await get_tree().create_timer(0.2).timeout  # Wait for the timeout signal after 1 second
	queue_free()  # Delete the fireball after 1 second

func _on_body_entered(body):
	if body.has_method("player_damage"):  # Ensure it only affects enemies
		body.player_damage()  # Example function on enemy
		queue_free()  # Remove the fireball after it hits an enemy

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()  # Remove the fireball if it goes off-screen
