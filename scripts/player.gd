extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2

@onready var jumps_remaining = MAX_JUMPS
@onready var was_on_floor = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound

func left_right_handler():
	# Get input direction: -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip sprite
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true
		
	# Play animations
	if is_on_floor():
		if direction == 0:
			sprite.play("idle")
		else:
			sprite.play("run")
	else:
		sprite.play("jump")
		
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()

func jump_handler():
	# Handle jump.
	if Input.is_action_just_pressed("jump") and jumps_remaining > 0:
		# Increment jump counter
		if not is_on_floor():
			jumps_remaining -= 1
		
		# Play sound
		jump_sound.play()
		
		# Apply movement
		velocity.y = JUMP_VELOCITY
		move_and_slide()

func down_handler():
	if Input.is_action_pressed("move_down") && is_on_floor():
		# Move one pixel down (assuming platform collision boxes are all 1px thick)
		position.y += 1
		move_and_slide()

func _physics_process(delta: float) -> void:
	# ALWAYS: add gravity
	velocity += get_gravity() * delta
	
	# ALWAYS: check how many jumps left
	if is_on_floor():
		jumps_remaining = MAX_JUMPS
	if was_on_floor and not is_on_floor():
		jumps_remaining -= 1
	was_on_floor = is_on_floor()

	# Handle possible movements (walk or jump)
	jump_handler()
	left_right_handler()
	down_handler()
