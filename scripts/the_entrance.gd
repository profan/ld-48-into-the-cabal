extends Spatial

onready var anim_player = get_node("anim_player")
onready var trigger_area_outside = get_node("trigger_outside")
onready var trigger_area_inside = get_node("trigger_inside")

var has_triggered_outside = false

func _ready():
	trigger_area_outside.connect("body_entered", self, "_on_body_entered_outside_area")
	trigger_area_inside.connect("body_entered", self, "_on_body_entered_inside_area")

func _on_body_entered_outside_area(body):
	if body.name == "player" and not has_triggered_outside:
		anim_player.play("open_the_gate")
		Game.trigger_player_activated_gate()
		has_triggered_outside = true

func _on_body_entered_inside_area(body):
	if body.name == "player" and has_triggered_outside:
		anim_player.play_backwards("open_the_gate")
		Game.trigger_player_entered_library()
		has_triggered_outside = false
