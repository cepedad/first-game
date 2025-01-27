extends CharacterBody2D

const SPEED = 130.0
const ACC_FACTOR =  1.1
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2
const ROLL_SPEED = 200
const ROLL_DURATION = 0.5

var jumps_remaining = MAX_JUMPS
var was_on_floor = false
var saved_direction = 1
var is_rolling = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var roll: Node2D = $Roll

func left_right_handler():
	# Get input direction: -1, 0, 1
	var input_direction = Input.get_axis("move_left", "move_right")
	
	# Save direction for later
	if input_direction != 0:
		saved_direction = input_direction
	
	# Flip sprite
	if input_direction > 0:
		sprite.flip_h = false
		
	elif input_direction < 0:
		sprite.flip_h = true
		
	# Apply movement
	if not roll.is_rolling():
		if input_direction:
			velocity.x = input_direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

func down_handler():
	if Input.is_action_pressed("move_down") && is_on_floor():
		# Move one pixel down (assuming platform collision boxes are all 1px thick)
		position.y += 1

func jump_handler():
	if Input.is_action_just_pressed("jump") and jumps_remaining > 0 and not roll.is_rolling():
		# Increment jump counter
		if not is_on_floor():
			jumps_remaining -= 1
		
		# Play sound
		jump_sound.play()
		
		# Apply movement
		velocity.y = JUMP_VELOCITY

func roll_handler():
	if Input.is_action_just_pressed("roll"):
		roll.start_roll(ROLL_DURATION)
		velocity.x = saved_direction * ROLL_SPEED

func play_animations():
	if roll.is_rolling():
		sprite.play("roll")
	else:
		if is_on_floor():
			if velocity.x == 0:
				sprite.play("idle")
			else:
				sprite.play("run")
		else:
			sprite.play("jump")
	

func _physics_process(delta: float) -> void:
	# ALWAYS: add gravity
	velocity += get_gravity() * delta
	
	# ALWAYS: check how many jumps left
	if is_on_floor():
		jumps_remaining = MAX_JUMPS
	if was_on_floor and not is_on_floor():
		jumps_remaining -= 1
	was_on_floor = is_on_floor()

	# Manipulate velocity from possible moving actions (walk or jump)
	left_right_handler()
	jump_handler()
	down_handler()
	roll_handler()
	
	# Play animations
	play_animations()
	
	# Use changed velocity to move
	move_and_slide()
