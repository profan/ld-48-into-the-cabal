extends Spatial

onready var trigger = get_node("particles/trigger")

var has_triggered = false

func _ready():
	trigger.connect("body_entered", self, "_on_body_enter_area")

func _on_body_enter_area(body):
	if body.name == "player" and not has_triggered:
		has_triggered = true
		Game.trigger_player_got_torch()
		queue_free()
