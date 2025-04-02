extends Node2D

func _ready():
	var player = get_node("/root/Game/Foreground/Characters/Player")  # Ensure this path is correct!
	player.health_depleted.connect(_on_player_health_depleted)
	
	var mini_boss = get_node("/root/Game/Foreground/Characters/Bosses/MiniBoss")
	mini_boss.health_depleted.connect(_on_mini_boss_health_depleted)

func _on_player_health_depleted():
	# Show Game Over screen
	%GameOver.visible = true
	
	# Play Game Over sound before pausing the game
	if %GameOverSound:
		%GameOverSound.play()

	# Pause the overworld music if it exists
	if %Overworld:
		%Overworld.stream_paused = true  # Pauses music without resetting it

	# Pause the game after sounds start
	await get_tree().create_timer(3).timeout
	get_tree().paused = true


func _on_mini_boss_health_depleted():
	%DarkWoods.visible = true


func _on_mini_boss_2_health_depleted() -> void:
	%Items.visible = false
	


func _on_final_boss_health_depleted() -> void:
	# Show Game Over screen
	%GameOver.visible = true
	
	# Play Game Over sound before pausing the game
	if %GameOverSound:
		%GameOverSound.play()

	# Pause the overworld music if it exists
	if %Overworld:
		%Overworld.stream_paused = true  # Pauses music without resetting it

	# Pause the game after sounds start
	await get_tree().create_timer(3).timeout
	get_tree().paused = true
