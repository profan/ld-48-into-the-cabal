extends KinematicBody

const Utils = preload("utils.gd")

onready var camera = get_node("camera")
onready var original_camera_translation = camera.translation
onready var glowstick = get_node("camera/ancient_glowstick")
onready var shape = get_node("shape")

var IS_NOCLIP_MODE = true

var OBJECT_PICKUP_DISTANCE = 4.0

var GRAVITY = -9.8 # 9.8 what? who the fuck
var FRICTION = 0.9
var AIR_FRICTION = 0.9

var BOB_SPEED = 0.5
var BOB_OFFSET = 0.5

var JUMP_FORCE = 32.0

var SENSITIVITY = 1.0
var DEGREES_PER_SECOND = 22.5
var MOVEMENT_ACCEL = 1.0 # units per second?
var MAX_SPEED = 48.0 # units per second?
var ACCEL = 1.0

var velocity: Vector3
var last_mouse_delta: Vector2

# glowstick bob/etc
var initial_glowstick_offset: Vector3 = Vector3.ZERO
var glowstick_offset: Vector3 = Vector3.ZERO
var glowstick_position_offset: Vector3 = Vector3.ZERO
var glowstick_velocity: Vector3 = Vector3.ZERO

var current_held_object: RigidBody = null

var pitch = 0
var yaw = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Game.connect("on_player_got_torch", self, "_on_player_got_torch")
	initial_glowstick_offset = glowstick.translation

func _on_player_got_torch():
	glowstick.visible = true

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

# cast a ray where player is looking and try to pick up the item?
func try_to_pick_up_item():
	
	var global_camera_position = camera.global_transform.origin
	var global_camera_direction = -camera.global_transform.basis.z
	var global_camera_far = global_camera_position + global_camera_direction * 100.0
	
	var space_state: PhysicsDirectSpaceState = get_world().direct_space_state
	var result = space_state.intersect_ray(
		global_camera_position,
		global_camera_far
	)
	
	# we've got a hit!
	if result and result.collider:
		
		var collider_obj = result.collider
		var distance_to_obj = (result.collider.global_transform.origin - global_transform.origin).length()
		
		if Utils.is_object_possible_to_pick_up(collider_obj) and distance_to_obj <= OBJECT_PICKUP_DISTANCE:
			
			if collider_obj.is_pickupable == false: return
			
			if collider_obj.is_holdable:
				current_held_object = collider_obj
				print("now holding: ", current_held_object.name)
				
			collider_obj.pick_up_object()
			
			print("picked up: ", collider_obj.name)
			

func try_to_drop_item():
	print("dropped: ", current_held_object.name)
	current_held_object.drop_object()
	current_held_object = null

func ease_in_cubic(v):
	return v * v * v

func apply_force_for_interactable():
	
	var global_camera_position = camera.global_transform.origin
	var global_camera_direction = -camera.global_transform.basis.z
	
	var carry_distance = 2.0 # tweakable? maybe?
	var carry_height_offset = Vector3(0.0, 0.0, 0.0)
	
	var object_position = current_held_object.global_transform.origin
	var desired_position = global_camera_position + global_camera_direction * carry_distance + carry_height_offset
	
	# also add player velocity
	var force_delta = (desired_position - object_position) + velocity / (1.0 / current_held_object.mass)
	var force_adj = ease_in_cubic(force_delta.length() / OBJECT_PICKUP_DISTANCE)
	var force_norm = force_delta.normalized()
	
	var current_obj_velocity = current_held_object.linear_velocity
	
	var force_scaled = force_norm * force_adj
	var force_relative_dot = force_norm.dot(current_obj_velocity)
	var current_force_magnitude = current_held_object.linear_velocity.length() 
	
	# if force_relative_dot < 1.0 and current_force_magnitude < 16.0:
	if current_force_magnitude < 8.0:
	
		# current_held_object.apply_impulse(object_position, force_norm)
		current_held_object.apply_central_impulse(force_scaled)
		# current_held_object

func is_currently_holding_object():
	return current_held_object != null

func _physics_process(delta):
	
	if IS_NOCLIP_MODE:
		if not shape.disabled:
			shape.disabled = true
	else:
		if shape.disabled:
			shape.disabled = false
	
	# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var time_since_start = OS.get_ticks_msec()
	var velocity_magnitude = velocity.length() / 64.0
	var glowstick_bob_vertical = camera.global_transform.basis.y
	var glowstick_sway_horizontal = camera.transform.basis.x
	
	glowstick_velocity += transform.basis.x * (-last_mouse_delta.x / 4.0) * delta
	
	if glowstick_velocity.length() > 2.0:
		glowstick_velocity = glowstick_velocity.normalized() * 2.0
	
	# glowstick_offset = glowstick_bob_vertical * (velocity_magnitude * sin(time_since_start / 150.0))
	glowstick_offset = glowstick_sway_horizontal * last_mouse_delta.x / 64.0
	glowstick.translation = initial_glowstick_offset + glowstick_velocity
	
	# var rotated_velocity = velocity.rotated(Vector3.UP, rotation.y)
	# glowstick_position_offset = transform.basis.x * last_mouse_delta.x / 64.0
	glowstick.set_view_velocity(-(velocity / 4.0) - glowstick_velocity)
	glowstick.rotation.y = -rotation.y
	
	glowstick_velocity *= 0.975
	
	var mouse_delta: Vector2 = Vector2.ZERO
	mouse_delta += last_mouse_delta * DEGREES_PER_SECOND * delta
	last_mouse_delta = Vector2.ZERO
	
	pitch += -mouse_delta.y
	yaw += -mouse_delta.x
	
	pitch = clamp(pitch, -89.9, 89.9)
	yaw = yaw
	
	rotation_degrees.y = yaw
	
	if IS_NOCLIP_MODE:
		rotation_degrees.x = pitch
		camera.rotation_degrees.x = 0.0
	else:
		camera.rotation_degrees.x = pitch
		rotation_degrees.x = 0.0
	
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
	
	if Input.is_action_just_pressed("move_pick_up"):
		if current_held_object: try_to_drop_item()
		else: try_to_pick_up_item()
	
	if Input.is_action_just_pressed("move_noclip_toggle"):
		IS_NOCLIP_MODE = not IS_NOCLIP_MODE
	
	if is_currently_holding_object():
		apply_force_for_interactable()
	
	camera.translation = original_camera_translation + camera_delta
	
	# zoop
	if IS_NOCLIP_MODE:
		pass
	else:
		movement_delta.y = 0
	
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		#var dir_vector = movement_delta.normalized().linear_interpolate(transform.basis.y, 0.75).normalized()
		# movement_delta += dir_vector * JUMP_FORCE
		movement_delta += Vector3.UP * JUMP_FORCE
	
	var gravity_vector
	if IS_NOCLIP_MODE:
		gravity_vector = Vector3.ZERO
	else:
		gravity_vector = floor_normal * -(GRAVITY*GRAVITY) * delta
	# if not is_on_floor() and not is_on_wall(): velocity += gravity_vector
	velocity += gravity_vector
	
	var movement_vector = movement_delta * MOVEMENT_ACCEL
	velocity += movement_vector
	
	if velocity.length() > MAX_SPEED:
		var normed = velocity.normalized()
		velocity = normed * MAX_SPEED
	
	var floor_angle = deg2rad(65.0)
	var stop_on_slope = false
	var max_slides = 4
	
	var remainder = move_and_slide(
		velocity, Vector3.UP, stop_on_slope,
		max_slides, floor_angle, true
	)
	
	velocity = remainder
	
	if is_on_floor():
		velocity *= FRICTION
	else:
		velocity *= AIR_FRICTION
