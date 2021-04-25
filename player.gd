extends KinematicBody

onready var camera = get_node("camera")
onready var original_camera_translation = camera.translation

var GRAVITY = -9.8 # 9.8 what? who the fuck
var FRICTION = 0.9
var AIR_FRICTION = 0.9

var JUMP_FORCE = 32.0

var SENSITIVITY = 1.0
var DEGREES_PER_SECOND = 22.5
var MOVEMENT_ACCEL = 1.25 # units per second?
var MAX_SPEED = 48.0 # units per second?
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
	

func get_actual_floor_normal() -> Vector3:
	var maybe_floor_normal = get_floor_normal()
	if not maybe_floor_normal:
		return Vector3.UP
	else:
		return maybe_floor_normal

func _physics_process(delta):
	
	var mouse_delta: Vector2 = Vector2.ZERO
	mouse_delta += last_mouse_delta * DEGREES_PER_SECOND * delta
	last_mouse_delta = Vector2.ZERO
	
	pitch += -mouse_delta.y
	yaw += -mouse_delta.x
	
	pitch = clamp(pitch, -89.9, 89.9)
	yaw = yaw
	
	rotation_degrees.y = yaw
	camera.rotation_degrees.x = pitch
	
	var camera_delta: Vector3 = Vector3.ZERO
	var movement_delta: Vector3 = Vector3.ZERO
	
	var floor_normal = get_actual_floor_normal()
	
	if Input.is_action_pressed("move_forward"):
		movement_delta += -transform.basis.z
	
	if Input.is_action_pressed("move_backwards"):
		movement_delta += transform.basis.z
		
	if Input.is_action_pressed("move_left"):
		movement_delta += -transform.basis.x
		
	if Input.is_action_pressed("move_right"):
		movement_delta += transform.basis.x
	
	if Input.is_action_pressed("move_crouch"):
		camera_delta.y = -1
	
	camera.translation = original_camera_translation + camera_delta
	
	# zoop
	movement_delta.y = 0
	
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		#var dir_vector = movement_delta.normalized().linear_interpolate(transform.basis.y, 0.75).normalized()
		# movement_delta += dir_vector * JUMP_FORCE
		movement_delta += Vector3.UP * JUMP_FORCE
	
	var gravity_vector = floor_normal * -(GRAVITY*GRAVITY) * delta
	# if not is_on_floor() and not is_on_wall(): velocity += gravity_vector
	velocity += gravity_vector
	
	var movement_vector = movement_delta * MOVEMENT_ACCEL
	velocity += movement_vector
	
	if velocity.length() > MAX_SPEED:
		var normed = velocity.normalized()
		velocity = normed * MAX_SPEED
	
	var floor_angle = deg2rad(47.5)
	var remainder = move_and_slide(
		velocity, Vector3.UP
	)
	
	velocity = remainder
	
	if is_on_floor():
		velocity *= FRICTION
	else:
		velocity *= AIR_FRICTION
