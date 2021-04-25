extends Node

func _ready():
	pass # Replace with function body.

static func is_object_possible_to_pick_up(obj: CollisionObject):
	return obj is RigidBody
