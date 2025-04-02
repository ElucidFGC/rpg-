extends CharacterBody2D

var health = 3
var direction = Vector2.ZERO
var random_direction = Vector2.ZERO  # Stores a random movement direction
var attack_range = 80  # Distance at which the enemy attacks
var attack_timer = 0.0  # Timer to prevent attack spam
@export var attack_cooldown = 1.5  # Time between attacks
@export var random_change_interval = 1.5  # Time between random movement changes
@export var spawn_offset = Vector2(30,0)  # Spawn offset for attack

@onready var player = get_node("/root/Game/Foreground/Characters/Player")
@onready var notifier = $VisibleOnScreenNotifier2D  # Ensure this node exists in the scene
@onready var anim_player = $AnimatedSprite2D

var random_timer = 0.0  # Timer for changing random movement
var tracking = false  # Enemy will only track when visible

func _ready():
	randomize()  # Ensures different enemies get different behavior
	pick_random_direction()  # Set an initial random movement

	# Connect visibility signals
	if notifier:
		notifier.screen_entered.connect(_on_screen_entered)
		notifier.screen_exited.connect(_on_screen_exited)

func _on_screen_entered():
	tracking = true  # Start tracking the player when on screen

func _on_screen_exited():
	tracking = false  # Stop tracking the player when off screen

func _physics_process(delta):
	# Update attack cooldown
	var input_dir = Vector2.ZERO  

	# Assuming velocity or a movement direction variable is controlling the enemy
	if velocity.x < 0:
		input_dir = Vector2.LEFT
		anim_player.play("Left")
	elif velocity.x > 0:
		input_dir = Vector2.RIGHT
		anim_player.play("Right")
	elif velocity.y < 0:
		input_dir = Vector2.UP
		anim_player.play("Up")
	elif velocity.y > 0:
		input_dir = Vector2.DOWN
		anim_player.play("Down")
	else:
		anim_player.stop()  # Stop the animation if the enemy isn't moving

	if attack_timer > 0:
		attack_timer -= delta

	# Only track the player if visible
	if tracking and player:
		var direction_to_player = global_position.direction_to(player.global_position)

		# Change random movement direction at set intervals
		random_timer -= delta
		if random_timer <= 0:
			pick_random_direction()  # Choose a new random movement
			random_timer = random_change_interval  # Reset timer

		# Blend random movement and tracking player movement
		var final_direction = (direction_to_player * 0.45 + random_direction * 0.55).normalized()

		# Restrict movement to cardinal directions (UP, DOWN, LEFT, RIGHT)
		change_direction(final_direction)

		# If the player is close, stop moving and attack
		if global_position.distance_to(player.global_position) < attack_range:
			velocity = Vector2.ZERO
			attack()
		else:
			velocity = direction * 50.0  # Move in the chosen direction

		move_and_slide()
		
		if is_on_wall():
			pick_random_direction()  # Change direction if a wall is hit

func pick_random_direction():
	var possible_directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	random_direction = possible_directions[randi() % possible_directions.size()]

func change_direction(new_direction: Vector2):
	if abs(new_direction.x) > abs(new_direction.y):  # Prioritize horizontal movement
		direction = Vector2(sign(new_direction.x), 0)
	else:  # Prioritize vertical movement
		direction = Vector2(0, sign(new_direction.y))

func attack():
	if attack_timer > 0:
		return  # Prevent attack spam

	if not player:
		return  # Ensure player exists before attacking

	# Determine direction to the player
	var direction_to_player = global_position.direction_to(player.global_position)

	# Check if the enemy is facing the player
	if direction.dot(direction_to_player) > 0.7:  # Higher than 0.7 means similar direction
		attack_timer = attack_cooldown  # Reset cooldown

		# Instantiate and set fireball direction
		var attack = preload("res://Scenes/enemyfireball.tscn").instantiate()
		get_parent().add_child(attack)
		attack.global_position = global_position + (direction * spawn_offset.length())
		attack.direction = direction  # Set direction before _ready()


func take_damage():
	health -= 1

	if health <= 0:
		drop_health_pickup()  # Call the function to drop an item
		queue_free()

func drop_health_pickup():
	if randi_range(0, 1) == 1:  # 50% chance (0 or 1)
		var health_pickup = preload("res://Scenes/health_pickup.tscn").instantiate()
		health_pickup.global_position = global_position  # Drop at enemy position
		get_parent().add_child(health_pickup)  # Add to the scene
