extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2

@onready var jump_counter = 0
@onready var was_on_floor = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound

func left_right_handler(was_on_floor: bool):
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
	if Input.is_action_just_pressed("jump") and jump_counter < MAX_JUMPS:
		# Increment jump counter
		jump_counter += 1
		
		# Play sound
		jump_sound.play()
		
		# Apply movement
		velocity.y = JUMP_VELOCITY
		move_and_slide()

func down_handler():
	if Input.is_action_pressed("move_down") && is_on_floor():
		position.y += 1
		move_and_slide()

func _physics_process(delta: float) -> void:
	# Constantly add gravity
	velocity += get_gravity() * delta
	
	# Check jump conditions
	if is_on_floor():
		jump_counter = 0
	if not is_on_floor() and was_on_floor:
		jump_counter += 1

	# Handle possible movements (jump, walking, falling thru platform, walking off ledge)
	jump_handler()
	was_on_floor = is_on_floor()
	left_right_handler(was_on_floor)
	down_handler()
