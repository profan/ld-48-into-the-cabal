extends Spatial

onready var anim_player = get_node("anim_player")

var has_closed = false

func _ready():
	anim_player.connect("animation_finished", self, "_on_animation_finished")

func close_gate_to_library():
	if has_closed: return
	anim_player.play("close_gate_to_library")
	has_closed = true

func _on_animation_finished(anim_name):
	Game.trigger_player_activated_dungeon()
