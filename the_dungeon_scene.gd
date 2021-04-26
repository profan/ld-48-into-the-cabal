extends Spatial

onready var gate_to_library = get_node("dungeon_gate_to_library")
onready var gate_to_dungeon = get_node("dungeon_gate")
onready var dungeon_four_way = get_node("dungeon_entry_point")

func _ready():
	Game.connect("on_player_got_torch", self, "_on_player_got_torch")
	
	var global_start_offset = dungeon_four_way.global_transform.origin
	Game.register_dungeon_start_offset(global_start_offset)

func _on_player_got_torch():
	gate_to_library.close_gate_to_library()
	gate_to_dungeon.open_gate_to_dungeon()
