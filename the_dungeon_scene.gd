extends Spatial

onready var gate_to_library = get_node("dungeon_gate_to_library")
onready var gate_to_dungeon = get_node("dungeon_gate")

func _ready():
	Game.connect("on_player_got_torch", self, "_on_player_got_torch")

func _on_player_got_torch():
	gate_to_library.close_gate_to_library()
	gate_to_dungeon.open_gate_to_dungeon()
