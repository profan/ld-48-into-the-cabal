extends RigidBody

var MAX_VELOCITY_MAGNITUDE = 16.0

var is_picked_up = false
var is_pickupable = true
var is_holdable = true

func _ready():
	pass

func pick_up_object():
	is_picked_up = true
	Game.trigger_item_picked_up(self)

func drop_object():
	is_picked_up = false
	Game.trigger_item_dropped(self)

func _integrate_forces(state):
	
	if not is_holdable: true
	
	var current_velocity_magnitude = state.linear_velocity.length()
	
	if is_picked_up:
		# state.angular_velocity = Vector3.ZERO
		gravity_scale = 0.0
		pass
	else:
		gravity_scale = 1.0
	
	var current_velocity_norm = state.linear_velocity.normalized()
	if current_velocity_magnitude > MAX_VELOCITY_MAGNITUDE:
		state.linear_velocity = current_velocity_norm * MAX_VELOCITY_MAGNITUDE
