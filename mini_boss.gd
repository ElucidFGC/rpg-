extends CharacterBody2D

signal health_depleted

var health = 1
var direction = Vector2.ZERO
var random_direction = Vector2.ZERO  # Stores a random movement direction
var attack_range = 128  # Distance at which the enemy attacks
var attack_timer = 0.0  # Timer to prevent attack spam

@export var attack_cooldown = 1.5  # Time between attacks
@export var random_change_interval = 1.5  # Time between random movement changes
@export var spawn_offset = Vector2(30,0)
@export var strafe_range = 64  # The range at which the enemy tries to stay away

@onready var player = get_tree().get_first_node_in_group("player")
@onready var notifier = $VisibleOnScreenNotifier2D  # Ensure this node exists in the scene
@onready var marker = $swordtoss/Marker2D  # Ensure this marker exists in the scene

const swordtossScene = preload("res://Scenes/swordtoss.tscn")

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
	if attack_timer > 0:
		attack_timer -= delta

	if tracking and player:
		var direction_to_player = global_position.direction_to(player.global_position)
		var distance_to_player = global_position.distance_to(player.global_position)

		var final_direction: Vector2

		# If too close, strafe left or right instead of moving randomly
		if distance_to_player < strafe_range:
			final_direction = direction_to_player.rotated(deg_to_rad(90)) # Strafe sideways
		else:
			final_direction = -direction_to_player # Move away from player

		# Normalize the direction and apply movement
		direction = final_direction.normalized()
		velocity = direction * 50.0

		# Attack when in range
		if distance_to_player < attack_range:
			attack()

	move_and_slide()

	# Handle collision detection
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
		return  # Prevents attacking if cooldown is still active

	attack_timer = attack_cooldown  # Reset attack cooldown

	if not player:
		return  # Prevent crash if player is missing

	# Create and add the projectile to the scene
	var swordtoss_instance = swordtossScene.instantiate()
	get_parent().add_child(swordtoss_instance)

	# Position the projectile at the correct spawn point
	if marker:
		swordtoss_instance.global_position = marker.global_position
	else:
		swordtoss_instance.global_position = global_position  # Fallback

	# Get direction toward the player
	var direction_to_player = global_position.direction_to(player.global_position)

	# Restrict direction to cardinal directions
	if abs(direction_to_player.x) > abs(direction_to_player.y):
		# Prioritize horizontal movement
		swordtoss_instance.direction = Vector2(sign(direction_to_player.x), 0)
	else:
		# Prioritize vertical movement
		swordtoss_instance.direction = Vector2(0, sign(direction_to_player.y))

	# Allow miniboss to move after attacking
	pick_random_direction()


func take_damage():
	health -= 1

	if health <= 0:
		health_depleted.emit()
		queue_free()
