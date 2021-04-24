extends KinematicBody

var GRAVITY = -22.5 # 9.8 what? who the fuck
var FRICTION = 0.9

var SENSITIVITY = 1.0
var DEGREES_PER_SECOND = 22.5
var MOVEMENT_ACCEL = 4.0 # units per second?
var MAX_SPEED = 32.0 # units per second?
var ACCEL = 1.0

var velocity: Vector3
var last_mouse_delta: Vector2

var pitch = 0
var yaw = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(ev):
	
	var screen_center = get_viewport().size / 2.0
	if ev is InputEventMouseMotion:
		last_mouse_delta += ev.relative
		# Input.warp_mouse_position(screen_center)
	
	if ev is InputEventKey:
		if ev.is_action_pressed("quit"):
			print("bye! :(")
			get_tree().quit()
	

func _physics_process(delta):
	
	var mouse_delta: Vector2 = Vector2.ZERO
	mouse_delta += last_mouse_delta * DEGREES_PER_SECOND * delta
	last_mouse_delta = Vector2.ZERO
	
	pitch += -mouse_delta.y
	yaw += -mouse_delta.x
	
	pitch = clamp(pitch, -89.9, 89.9)
	yaw = yaw
	
	rotation_degrees.y = yaw
	rotation_degrees.x = pitch
	
	var movement_delta: Vector3 = Vector3.ZERO
	var floor_normal = get_floor_normal()
	
	if Input.is_action_pressed("move_forward"):
		movement_delta += -transform.basis.z
	
	if Input.is_action_pressed("move_backwards"):
		movement_delta += transform.basis.z
		
	if Input.is_action_pressed("move_left"):
		movement_delta += -transform.basis.x
		
	if Input.is_action_pressed("move_right"):
		movement_delta += transform.basis.x
	
	# zoop
	movement_delta.y = 0
	
	var gravity_vector = Vector3.UP * -(GRAVITY*GRAVITY) * delta
	if not is_on_floor() and not is_on_wall(): velocity += gravity_vector
	
	var movement_vector = movement_delta * MOVEMENT_ACCEL
	velocity += movement_vector
	
	if velocity.length() > MAX_SPEED:
		var normed = velocity.normalized()
		velocity = normed * MAX_SPEED
	
	var remainder = move_and_slide(velocity)
	# velocity -= remainder
	velocity *= FRICTION
