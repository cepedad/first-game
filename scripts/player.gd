extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var jump_counter

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound

func jump_handler(delta: float) -> void:
	# Reset jump
	if is_on_floor():
		jump_counter = 0
	
	# Add the gravity.
	if not is_on_floor() :
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and jump_counter <= 1:
		jump_counter += 1
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

func left_right_handler(delta: float) -> void:
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

func _input(event: InputEvent):
	if (event.is_action_pressed("move_down") && is_on_floor()):
		position.y += 1

func _physics_process(delta: float) -> void:
	jump_handler(delta)
	left_right_handler(delta)
