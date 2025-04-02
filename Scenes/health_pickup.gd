extends Area2D

signal health_restored  # Optional signal if needed

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))  # Ensure it's connected

func _on_body_entered(body):
	if body is CharacterBody2D and body.has_method("restore_health"):
		print("Health pickup touched by player")  # Debugging line
		body.restore_health()  # Call the player's restore function
		queue_free()  # Destroy the heart pickup
