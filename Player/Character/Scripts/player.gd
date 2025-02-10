extends CharacterBody2D

signal health_depleted

var health = 3
const MARKER_OFFSET = 50
const FireballScene = preload("res://Scenes/Fireball.tscn")
const SPEED = 200

var last_direction = Vector2.RIGHT  # Default direction

func _physics_process(delta):
	var input_dir = Vector2.ZERO  

	if Input.is_action_pressed("move_left"):
		input_dir = Vector2.LEFT 
	elif Input.is_action_pressed("move_right"):
		input_dir = Vector2.RIGHT 
	elif Input.is_action_pressed("move_up"):
		input_dir = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		input_dir = Vector2.DOWN

	# Update last direction if moving
	if input_dir != Vector2.ZERO:
		last_direction = input_dir
		$Fireball/Marker2D.position = last_direction.normalized() * MARKER_OFFSET
		$Fireball/Marker2D.rotation = last_direction.angle()

	velocity = input_dir * SPEED
	move_and_slide()

	# Fireball shooting logic
	if Input.is_action_just_pressed("shoot"):  
		var fireball_instance = FireballScene.instantiate()
		get_parent().add_child(fireball_instance)
		fireball_instance.global_position = $Fireball/Marker2D.global_position

		# Fire in the last direction moved
		fireball_instance.direction = last_direction

func player_damage():
	health -= 0.5
	if health <= 0.0:
			health_depleted.emit()
