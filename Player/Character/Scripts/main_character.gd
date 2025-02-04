extends CharacterBody2D

const MARKER_OFFSET = 50
const FireballScene = preload("res://Fireball.tscn")

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * 100
	move_and_slide()
	
	if direction != Vector2.ZERO:
		$Fireball/Marker2D.rotation = direction.angle()
		$Fireball/Marker2D.position = direction.normalized() * MARKER_OFFSET

		if Input.is_action_just_pressed("shoot"):  # Use a custom action like "shoot"
			var fireball_instance = FireballScene.instantiate()
			get_parent().add_child(fireball_instance)
			fireball_instance.global_position = $Fireball/Marker2D.global_position

			# Use the directional input if available, otherwise default to right.
			if direction != Vector2.ZERO:
				fireball_instance.direction = direction
			else:
				fireball_instance.direction = Vector2.RIGHT
