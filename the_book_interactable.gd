extends "res://scripts/pickupable_item.gd"

func _ready():
	Game.connect("on_player_activated_passage", self, "_on_passage_activated")

func _on_passage_activated():
	# is_pickupable = false
	pass
