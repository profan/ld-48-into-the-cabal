extends Spatial

onready var trigger_area = get_node("trigger_area")

var throne_approached = false

func _ready():
	trigger_area.connect("body_entered", self, "_on_player_approach_throne")

func _on_player_approach_throne(body):
	if body.name == "player" and not throne_approached:
		throne_approached = true
		Game.request_text_print("librarian, maybe now it is safe to restore the library")
		Game.request_text_print("- with your guidance, what has been kept can be restored")
		Game.request_text_print("... thanks for playing! :D")
		
		yield(get_tree().create_timer(10.0), "timeout")
		Game.request_fade(4.0)
		yield(get_tree().create_timer(2.0), "timeout")
		get_tree().quit()
