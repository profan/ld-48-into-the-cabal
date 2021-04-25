extends Spatial

onready var anim_player = get_node("anim_player")
onready var trigger_area = get_node("trigger")

var has_triggered = false

func _ready():
	trigger_area.connect("body_entered", self, "_on_body_entered_area")

func _on_body_entered_area(body):
	if body.name == "player" and not has_triggered:
		anim_player.play("open_the_gate")
		has_triggered = true
