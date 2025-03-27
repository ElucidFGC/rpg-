extends Area2D

var mini_boss_defeated = false  # Flag to check if the mini-boss has been defeated

func _ready():
	var mini_boss = get_node("/root/Game/Foreground/Characters/Bosses/MiniBoss")
	mini_boss.health_depleted.connect(_on_mini_boss_health_depleted)  # Connect to signal

func _on_body_entered(body: Node2D) -> void:
	# Check if the mini-boss health is depleted before teleporting the player
	if mini_boss_defeated and body.is_in_group("player"):  # Ensure mini-boss is defeated
		body.global_position = $DestinationPoint.global_position  # Teleport player

func _on_mini_boss_health_depleted() -> void:
	# This function is called when the mini-boss health is depleted
	mini_boss_defeated = true  # Set the flag to true when mini-boss is defeated
