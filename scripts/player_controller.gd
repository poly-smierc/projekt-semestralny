extends CharacterBody2D
class_name PlayerController

const SPEED = 150.0
const JUMP_VELOCITY = -230.0
const JUMP_GRAVITY = 400.0
const FALL_GRAVITY = 510.0
const ACCELERATION = 900.0
const JUMP_HEIGHT_THRESHOLD = -85.0
const VEL_CAMERA_SMOOTHING_THRESHOLD = 300.0
const BASE_SMOOTHING = 5.0
const SMOOTHING_MULTIPLIER = 0.05
const MAX_SMOOTH = 50.0
const IMPACT_DURATION = 0.05

# These must be oneshot timers
@export var coyote_timer : Timer
@export var jump_buffer_timer : Timer
@export var health : HealthComponent
@export var camera : Camera2D

# variables to handle coyote time and jump buffering
var coyote_time_used := false
var jump_buffer := false


func _ready() -> void:
	assert(coyote_timer, "Coyote timer is required!")
	assert(jump_buffer_timer, "Jump buffer is required!")
	assert(health, "Health component is required!")


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
	
	
func _store_jump() -> void:
	jump_buffer = true
	jump_buffer_timer.start()
	

# Purpose: Introduce variable jump height
func _cut_jump() -> void:
	if velocity.y<JUMP_HEIGHT_THRESHOLD:
		velocity.y = JUMP_HEIGHT_THRESHOLD
	

# Purpose: Make sure that with higher velocities, player is still on camera
func _lerp_camera_smoothing() -> void:
	if not camera:
		return
	
	var speed := velocity.length()
	if speed>VEL_CAMERA_SMOOTHING_THRESHOLD:
		# a linear function to modify smoothing speed
		var new_smooth = SMOOTHING_MULTIPLIER*(speed-VEL_CAMERA_SMOOTHING_THRESHOLD)+BASE_SMOOTHING
		camera.position_smoothing_speed = min(new_smooth, MAX_SMOOTH)
	else:
		camera.position_smoothing_speed = BASE_SMOOTHING
		
		
# Purpose: Add some oomph when landing from a fall
func _camera_floor_impact():
	if not camera:
		return
	
	if camera.position_smoothing_speed != BASE_SMOOTHING:
		var tween := create_tween()
		var smoothing_speed_vector := Vector2(0, camera.position_smoothing_speed*2)
		var new_camera_pos = camera.position+smoothing_speed_vector
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(camera, "position", new_camera_pos, IMPACT_DURATION)
		tween.tween_property(camera, "position", camera.position, IMPACT_DURATION)
		tween.play()
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	# If we jump, gravity has lower impact on us
	# This gives us a nice jump curve
	if not is_on_floor():
		if velocity.y>0:
			velocity.y += JUMP_GRAVITY * delta
		else:
			velocity.y += FALL_GRAVITY * delta
			
		if not coyote_time_used and coyote_timer.is_stopped():
			coyote_timer.start()
	else:
		coyote_time_used = false
		velocity.y = 0.0
		_camera_floor_impact()
		
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
		
	_lerp_camera_smoothing()
	move_and_slide()


# Purpose: Handle timer timeouts
func _on_coyote_timer_timeout() -> void:
	coyote_time_used = true
	
	
func _on_jump_buffer_timer_timeout() -> void:
	jump_buffer = false


func _on_health_damage_taken(damage: int) -> void:
	pass # Replace with function body, after adding art and sound


func _on_health_healed(amount: int) -> void:
	pass # Replace with function body, after adding art and sound


func _on_health_died() -> void:
	# Preserve the camera from annhilation, assuming we have it
	if camera:
		camera.reparent(get_parent())
	queue_free()
