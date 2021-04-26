extends "res://scripts/pickupable_item.gd"

func _ready():
	is_holdable = false

func pick_up_object():
	Game.trigger_player_got_torch()
	queue_free()
