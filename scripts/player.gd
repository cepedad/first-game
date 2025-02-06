extends CharacterBody2D

### CONSTANTS
# Horizontal Movement
const GROUND_SPEED = 130.0
const AIR_SPEED = 130.0
const GROUND_DEC_FACTOR = 0.20
const MIDAIR_ACC_FACTOR = 0.15
const MIDAIR_DEC_FACTOR = 0.20
# Jumping
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2
const SHORT_HOP_WINDOW = 5
const SHORT_HOP_FACTOR = 0.67
const COYOTE_TIME_FRAMES = 5
# Rolling
const ROLL_SPEED = 200
const ROLL_DURATION = 0.5
const AIRDODGE_DURATION = 0.15
const AIRDODGE_HANG_DURATION = 0.20
const AIRDODGE_SPEED = 200

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
@onready var airdodge: Node2D = $Airdodge

func left_right_handler():
	# Get input direction: -1, 0, 1
	var input_direction = Input.get_axis("move_left", "move_right")
	
	# Save direction for later
	if input_direction != 0:
		saved_direction = input_direction
		
	# Apply movement
	if not roll.is_rolling() and not airdodge.is_airdodging():
		if input_direction:
			if is_on_floor():
				velocity.x = input_direction * GROUND_SPEED
			else:
				velocity.x = lerp(velocity.x, input_direction * AIR_SPEED, MIDAIR_ACC_FACTOR)
		else:
			if is_on_floor():
				velocity.x = lerp(velocity.x, 0.0, GROUND_DEC_FACTOR)
			else:
				velocity.x = lerp(velocity.x, 0.0, MIDAIR_DEC_FACTOR)

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
			velocity.y *= SHORT_HOP_FACTOR

func roll_handler():
	if Input.is_action_just_pressed("roll") and is_on_floor() and not roll.is_rolling():
		roll.start_roll(ROLL_DURATION)
		velocity.x = saved_direction * ROLL_SPEED
		
	if roll.is_rolling():
		set_collision_layer_value(2, false)
	else:
		set_collision_layer_value(2, true)
		
func airdodge_handler():
	var h_input_direction = Input.get_axis("move_left", "move_right")
	var v_input_direction = Input.get_axis("move_up", "move_down")
	
	if Input.is_action_just_pressed("roll") and not is_on_floor() and not airdodge.is_airdodging():
		airdodge.start_airdodge(AIRDODGE_DURATION, AIRDODGE_HANG_DURATION)
	if airdodge.is_airdodging():
		if h_input_direction != 0 and v_input_direction != 0:
			velocity.x = h_input_direction * AIRDODGE_SPEED / sqrt(2)
			velocity.y = v_input_direction * AIRDODGE_SPEED / sqrt(2)
		else:
			velocity.x = h_input_direction * AIRDODGE_SPEED
			velocity.y = v_input_direction * AIRDODGE_SPEED
	if airdodge.is_hanging() and not is_on_floor():
		velocity.x = 0
		velocity.y = 0

func play_animations():
	if roll.is_rolling():
		sprite.play("roll")
	elif airdodge.is_airdodging() or airdodge.is_hanging():
		pass
	else:
		# Flip sprite
		if saved_direction > 0:
			sprite.flip_h = false
		elif saved_direction < 0:
			sprite.flip_h = true
		if is_on_floor():
			if velocity.x > -1 * GROUND_SPEED and velocity.x < GROUND_SPEED:
				sprite.play("idle")
			else:
				sprite.play("run")
		else:
			sprite.play("jump")

func _physics_process(delta: float) -> void:
	# ALWAYS: add gravity
	if not airdodge.is_airdodging() and not airdodge.is_hanging():
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
	airdodge_handler()
	
	# Play animations
	play_animations()
	
	# Use changed velocity to move
	move_and_slide()
