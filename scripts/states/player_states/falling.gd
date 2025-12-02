class_name Falling extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass
	
func exit() -> void:
	pass
	
func handle_input(_event: InputEvent) -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	player.velocity += player.get_gravity() * _delta
	
	# Set sprite direction
	if direction > 0:
		player.sprite.flip_h = false
	elif direction < 0:
		player.sprite.flip_h = true
	
	# Apply movement
	if direction:
		player.velocity.x = direction * player.SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	player.move_and_slide()
	
	if player.is_on_floor():
		if is_equal_approx(direction, 0.0):
			finished.emit(IDLE)
		else:
			finished.emit(RUNNING)
