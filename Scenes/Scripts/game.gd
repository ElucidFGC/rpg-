extends Node2D

func _ready():
	var player = get_node("/root/Game/Foreground/Characters/Player")  # Ensure this path is correct!
	player.health_depleted.connect(_on_player_health_depleted)

func _on_player_health_depleted():
	%GameOver.visible = true
	get_tree().paused = true
