extends CharacterBody2D

signal health_depleted

var health = 3
const MARKER_OFFSET = 16
const FireballScene = preload("res://Scenes/fireball.tscn")
const SPEED = 100
const SHOOT_COOLDOWN = 0.5  # Cooldown period (in seconds)

var last_direction = Vector2.RIGHT  # Default direction
var can_shoot = true

@onready var anim_player = $AnimatedSprite2D  # Ensure this node exists in your scene

func _physics_process(delta):
	var input_dir = Vector2.ZERO  

	if Input.is_action_pressed("move_left"):
		input_dir = Vector2.LEFT 
		anim_player.play("Walk L")
	elif Input.is_action_pressed("move_right"):
		input_dir = Vector2.RIGHT 
		anim_player.play("Walk R")
	elif Input.is_action_pressed("move_up"):
		input_dir = Vector2.UP
		anim_player.play("Walk U")
	elif Input.is_action_pressed("move_down"):
		input_dir = Vector2.DOWN
		anim_player.play("Walk D")
	else:
		anim_player.stop()  # Stop the animation if no input is detected

	# Update last direction if moving
	if input_dir != Vector2.ZERO:
		last_direction = input_dir
		$Fireball/Marker2D.position = last_direction.normalized() * MARKER_OFFSET
		$Fireball/Marker2D.rotation = last_direction.angle()

	velocity = input_dir * SPEED
	move_and_slide()

	# Fireball shooting logic
	if Input.is_action_just_pressed("shoot") and can_shoot:  
		var fireball_instance = FireballScene.instantiate()
		get_parent().add_child(fireball_instance)
		fireball_instance.global_position = $Fireball/Marker2D.global_position

		# Fire in the last direction moved
		fireball_instance.direction = last_direction
		can_shoot = false
		
		var timer = get_tree().create_timer(SHOOT_COOLDOWN)
		await timer.timeout  # Await the timeout signal from the timer
		can_shoot = true

func player_damage():
	health -= 0.5
	if health <= 0.0:
		health_depleted.emit()
