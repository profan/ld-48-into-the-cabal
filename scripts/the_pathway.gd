extends Spatial

onready var anim_player = get_node("anim_player")
onready var trigger_activate_area = get_node("trigger")
onready var trigger_close_area = get_node("trigger_close")

var has_triggered = false
var has_triggered_close = false

func _ready():
	trigger_activate_area.connect("body_entered", self, "_on_body_enter_activate_area")
	trigger_close_area.connect("body_entered", self, "_on_body_entered_close_area")

func _on_body_enter_activate_area(body):
	if body.name == "player" and not has_triggered:
		anim_player.play("open_the_pathway")
		Game.trigger_player_activated_passage()
		has_triggered = true

func _on_body_entered_close_area(body):
	if body.name == "player" and not has_triggered_close:
		anim_player.play_backwards("open_the_pathway")
		Game.trigger_player_entered_passage()
		has_triggered_close = true
