extends CharacterBody2D

var health = 3
var direction = Vector2.ZERO
var random_direction = Vector2.ZERO  # Stores a random movement direction
var attack_range = 32  # Distance at which the enemy attacks
var attack_timer = 0.0  # Timer to prevent attack spam
@export var attack_cooldown = 1.5  # Time between attacks
@export var random_change_interval = 1.5  # Time between random movement changes
@export var spawn_offset = Vector2(30,0)

@onready var player = get_node("/root/Game/Foreground/Characters/Player")

var random_timer = 0.0  # Timer for changing random movement

func _ready():
	randomize()  # Ensures different enemies get different behavior
	pick_random_direction()  # Set an initial random movement

func _physics_process(delta):
	# Update attack cooldown
	if attack_timer > 0:
		attack_timer -= delta

	# Ensure player exists before proceeding
	if player:
		var direction_to_player = global_position.direction_to(player.global_position)

		# Change random movement direction at set intervals
		random_timer -= delta
		if random_timer <= 0:
			pick_random_direction()  # Choose a new random movement
			random_timer = random_change_interval  # Reset timer

		# Blend random movement and tracking player movement
		var final_direction = (direction_to_player * 0.7 + random_direction * 0.3).normalized()

		# Restrict movement to cardinal directions (UP, DOWN, LEFT, RIGHT)
		change_direction(final_direction)

		# If the player is close, stop moving and attack
		if global_position.distance_to(player.global_position) < attack_range:
			velocity = Vector2.ZERO
			attack()
		else:
			velocity = direction * 50.0  # Move in the chosen direction

		move_and_slide()

func pick_random_direction():
	var possible_directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	random_direction = possible_directions[randi() % possible_directions.size()]

func change_direction(new_direction: Vector2):
	if abs(new_direction.x) > abs(new_direction.y):  # Prioritize horizontal movement
		direction = Vector2(sign(new_direction.x), 0)
	else:  # Prioritize vertical movement
		direction = Vector2(0, sign(new_direction.y))

func attack():
	if attack_timer <= 0:
		attack_timer = attack_cooldown  # Reset the attack timer
		
		if not player:
			return
			
		var direction_to_player = global_position.direction_to(player.global_position)

		# Snap to the nearest cardinal direction
		var attack_direction = Vector2.ZERO
		if abs(direction_to_player.x) > abs(direction_to_player.y):
			attack_direction = Vector2(sign(direction_to_player.x), 0)  # Left or Right
		else:
			attack_direction = Vector2(0, sign(direction_to_player.y))  # Up or Down

		# Instantiate the attack
		var attack = preload("res://Scenes/attack.tscn").instantiate()
		get_parent().add_child(attack)  # Add the attack to the scene tree
		
		# Position the attack in front of the enemy in the cardinal direction
		attack.position = global_position + (attack_direction * spawn_offset.length())

		# Set the attack's velocity toward the player (if it's a moving attack)
		attack.velocity = attack_direction * 100  # Adjust speed as needed



func take_damage():
	health -= 1

	if health <= 0:
		queue_free()
