extends CharacterBody2D
class_name PlayerController

const SPEED = 150.0
const JUMP_VELOCITY = -210.0
const GRAVITY = 400.0
const ACCELERATION = 900.0
const JUMP_HEIGHT_THRESHOLD = -80.0

# These must be oneshot timers
@export var coyote_timer : Timer
@export var jump_buffer_timer : Timer

# variables to handle coyote time and jump buffering
var coyote_time_used := false
var jump_buffer := false


func _ready() -> void:
	assert(coyote_timer, "Coyote timer is required!")
	assert(jump_buffer_timer, "Jump buffer is required!")


# Purpose: Handle Coyote time
func _can_jump() -> bool:
	return is_on_floor() or \
	(not is_on_floor() and not coyote_time_used)


func _jump() -> void:
	velocity.y = JUMP_VELOCITY
	coyote_time_used = true
	jump_buffer = false
	if not jump_buffer_timer.is_stopped():
		jump_buffer_timer.stop()
	
	
func _store_jump():
	jump_buffer = true
	jump_buffer_timer.start()
	

# Purpose: Introduce variable jump height
func _cut_jump():
	if velocity.y<JUMP_HEIGHT_THRESHOLD:
		velocity.y = JUMP_HEIGHT_THRESHOLD
	
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if not coyote_time_used and coyote_timer.is_stopped():
			coyote_timer.start()
	else:
		coyote_time_used = false
		velocity.y = 0.0
		
		if jump_buffer:
			_jump()

	# Handle jump
	if Input.is_action_just_pressed("jump"):
		if _can_jump():
			_jump()
		else:
			_store_jump()
	
	# Handle variable jump height
	if Input.is_action_just_released("jump"):
		_cut_jump()

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction*SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION*delta)

	move_and_slide()


# Purpose: Handle timer timeouts
func _on_coyote_timer_timeout() -> void:
	coyote_time_used = true
	
	
func _on_jump_buffer_timer_timeout() -> void:
	jump_buffer = false
