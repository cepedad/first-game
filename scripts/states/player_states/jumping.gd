class_name Jumping extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y = player.JUMP_VELOCITY
	player.jump_sound.play()
	
func exit() -> void:
	pass
	
func handle_input(_event: InputEvent) -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
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
	
	if player.velocity.y <= 0:
		finished.emit(FALLING)
