extends CharacterBody2D

### CONSTANTS
# Horizontal Movement
const SPEED = 130.0
const DEC_FACTOR =  0.2
# Jumping
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2
const SHORT_HOP_WINDOW = 5
const SHORT_HOP_VELOCITY_FACTOR = 2.0/3.0
const COYOTE_TIME_FRAMES = 5
# Rolling
const ROLL_SPEED = 200
const ROLL_DURATION = 0.5

### Helper Flags
# Horizontal Movement
var saved_direction = 1
# Jumping
var jumps_remaining = MAX_JUMPS
var frames_since_on_floor = 0
# Rolling
var is_rolling = false

### Interactable Nodes
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var roll: Node2D = $Roll

func left_right_handler():
	# Get input direction: -1, 0, 1
	var input_direction = Input.get_axis("move_left", "move_right")
	
	# Save direction for later
	if input_direction != 0:
		saved_direction = input_direction
		
	# Apply movement
	if not roll.is_rolling():
		if input_direction:
			velocity.x = input_direction * SPEED
		else:
			velocity.x = lerp(velocity.x, 0.0, DEC_FACTOR)

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
		
	if Input.is_action_just_released("jump"):
		if frames_since_on_floor <= SHORT_HOP_WINDOW:
			velocity.y *= SHORT_HOP_VELOCITY_FACTOR

func roll_handler():
	if Input.is_action_just_pressed("roll") and not roll.is_rolling():
		roll.start_roll(ROLL_DURATION)
		velocity.x = saved_direction * ROLL_SPEED
		
	if roll.is_rolling():
		set_collision_layer_value(2, false)
	else:
		set_collision_layer_value(2, true)

func play_animations():
	if roll.is_rolling():
		sprite.play("roll")
	else:
		# Flip sprite
		if saved_direction > 0:
			sprite.flip_h = false
		elif saved_direction < 0:
			sprite.flip_h = true
		if is_on_floor():
			if velocity.x < SPEED:
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
		frames_since_on_floor = 0
		jumps_remaining = MAX_JUMPS
	else:
		frames_since_on_floor += 1
	if frames_since_on_floor == (COYOTE_TIME_FRAMES + 1) and not is_on_floor():
		jumps_remaining -= 1
	

	# Manipulate velocity from possible moving actions (walk, jump, roll, drop down)
	left_right_handler()
	jump_handler()
	down_handler()
	roll_handler()
	
	# Play animations
	play_animations()
	
	# Use changed velocity to move
	move_and_slide()
