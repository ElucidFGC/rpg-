extends CharacterBody2D

signal health_depleted  # Signal for when the boss dies

@export var max_health := 15  # Starting health
@export var attack_range := 128  # Attack distance
@export var attack_cooldown := 1.5  # Time between attacks
@export var speed := 50  # Movement speed
@export var flee_threshold := 0.5  # Switch to fleeing at 50% HP
@export var spawn_offset := Vector2(30, 0)  # Attack spawn offset
@export var strafe_range := 64  # Distance at which the boss strafes when fleeing

@export var knockback_duration := 2.0  # Time before chasing again
@export var knockback_force := 100  # How fast the boss retreats

@onready var player = get_tree().get_first_node_in_group("player")
@onready var notifier = $VisibleOnScreenNotifier2D
@onready var marker = $swordtoss/Marker2D  # Marker for projectile spawn
@onready var anim_player = $AnimatedSprite2D
@onready var damage_reset_timer = $DamageResetTimer  # Ensure this timer exists in the scene

const swordtossScene = preload("res://Scenes/swordtoss.tscn")  # Projectile attack scene

var health
var attack_timer := 0.0
var tracking := false  # Whether to track the player
var fleeing := false  # Whether the boss is running away

var knockback_timer := 0.0  # Timer for knockback state
var is_knocked_back := false  # Flag for knockback state

var can_damage := true  # Prevent multiple damage triggers per frame

func _ready():
	health = max_health  # Set initial health
	randomize()
	if notifier:
		notifier.screen_entered.connect(_on_screen_entered)
		notifier.screen_exited.connect(_on_screen_exited)

func _on_screen_entered():
	tracking = true

func _on_screen_exited():
	tracking = false

func _physics_process(delta):
	# Handle knockback behavior
	if is_knocked_back:
		knockback_timer -= delta
		if knockback_timer <= 0:
			is_knocked_back = false  # Resume normal behavior
		move_and_slide()
		return  # Stop normal behavior while knocked back

	if attack_timer > 0:
		attack_timer -= delta

	if tracking and player:
		var direction_to_player = global_position.direction_to(player.global_position)
		var distance_to_player = global_position.distance_to(player.global_position)

		if fleeing:
			handle_flee_behavior(direction_to_player, distance_to_player)
		else:
			handle_chase_behavior(direction_to_player, distance_to_player)

	move_and_slide()

func handle_chase_behavior(direction_to_player: Vector2, distance_to_player: float):
	# Force movement to cardinal directions only
	var move_direction := Vector2.ZERO
	if abs(direction_to_player.x) > abs(direction_to_player.y):
		move_direction = Vector2(sign(direction_to_player.x), 0)  # Left or Right
	else:
		move_direction = Vector2(0, sign(direction_to_player.y))  # Up or Down

	velocity = move_direction * speed  # Move toward player

	# Play correct animation
	if move_direction.x < 0:
		anim_player.play("Left")
	elif move_direction.x > 0:
		anim_player.play("Right")
	elif move_direction.y < 0:
		anim_player.play("Up")
	elif move_direction.y > 0:
		anim_player.play("Down")

	# Handle damage on collision
	if distance_to_player < 20 and can_damage:
		if player.has_method("player_damage"):
			player.player_damage()  # Call player damage function

			can_damage = false  # Prevent instant multiple damage
			damage_reset_timer.start()  # Start the cooldown timer

			# Push boss slightly away after attacking
			global_position += velocity.normalized() * -2  # Moves boss slightly back
			knockback(move_direction)  # Apply knockback after attacking

	if health <= max_health * flee_threshold:
		fleeing = true  # Switch to fleeing mode


func handle_flee_behavior(direction_to_player: Vector2, distance_to_player: float):
	var final_direction: Vector2

	# Move only in cardinal directions while fleeing
	if abs(direction_to_player.x) > abs(direction_to_player.y):
		final_direction = Vector2(sign(-direction_to_player.x), 0)
	else:
		final_direction = Vector2(0, sign(-direction_to_player.y))

	velocity = final_direction * speed

	# Set fleeing animation based on movement direction
	if final_direction.x < 0:
		anim_player.play("Left")
	elif final_direction.x > 0:
		anim_player.play("Right")
	elif final_direction.y < 0:
		anim_player.play("Up")
	elif final_direction.y > 0:
		anim_player.play("Down")

	# Attack when in range
	if distance_to_player < attack_range:
		attack()

func attack():
	if attack_timer > 0:
		return

	attack_timer = attack_cooldown

	var swordtoss_instance = swordtossScene.instantiate()
	get_parent().add_child(swordtoss_instance)

	# Spawn at marker position if available, else at boss position
	if marker:
		swordtoss_instance.global_position = marker.global_position
	else:
		swordtoss_instance.global_position = global_position

	# Get direction toward player and limit to cardinal directions
	var direction_to_player = global_position.direction_to(player.global_position)

	if abs(direction_to_player.x) > abs(direction_to_player.y):
		swordtoss_instance.direction = Vector2(sign(direction_to_player.x), 0)
	else:
		swordtoss_instance.direction = Vector2(0, sign(direction_to_player.y))

func take_damage():
	health -= 1
	if health <= 0:
		health_depleted.emit()
		queue_free()

func knockback(direction_to_player: Vector2):
	is_knocked_back = true
	knockback_timer = knockback_duration

	# Move away from the player in cardinal direction
	if abs(direction_to_player.x) > abs(direction_to_player.y):
		velocity = Vector2(sign(-direction_to_player.x), 0) * knockback_force
	else:
		velocity = Vector2(0, sign(-direction_to_player.y)) * knockback_force

# Reset damage cooldown
func _on_DamageResetTimer_timeout():
	can_damage = true
