extends Spatial

onready var anim_player = get_node("anim_player")

var has_opened = false

func _ready():
	pass

func open_gate_to_dungeon():
	if has_opened: return
	anim_player.play("open_gate_to_dungeon")
	has_opened = true
