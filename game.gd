extends Node

# pre dungeon

signal on_player_activated_gate
signal on_player_entered_library
signal on_player_activated_passage
signal on_player_entered_passage
signal on_player_got_torch
signal on_player_activated_dungeon
signal on_player_entered_dungeon

signal on_item_picked_up
signal on_item_dropped

var _has_player_entered_library = false
var _has_player_entered_passage = false
var _world_environment: WorldEnvironment = null

# dungeon
signal on_dungeon_success
signal on_dungeon_failed
signal on_dungeon_step(dir)
signal on_dungeon_enter_four_way(which)

var _dungeon_progress = []

func _ready():
	pass
	
enum Direction {
	Forward,
	Left,
	Right
}

func clear_dungeon_steps():
	_dungeon_progress.clear()

func register_dungeon_step(dir):
	_dungeon_progress.append(dir)

func trigger_dungeon_enter_four_way(which):
	emit_signal("on_dungeon_enter_four_way", which)

func trigger_next_dungeon_section(dir):
	register_dungeon_step(dir)

func set_world_environment_depth(new_depth: int):
	if _world_environment:
		_world_environment.environment.fog_depth_end = new_depth

func get_world_environment() -> WorldEnvironment:
	return _world_environment

func register_world_environment(obj: WorldEnvironment):
	_world_environment = obj

func has_player_entered_library() -> bool:
	return _has_player_entered_library

func has_player_entered_passage() -> bool:
	return _has_player_entered_passage

func trigger_player_activated_dungeon():
	emit_signal("on_player_activated_dungeon")

func trigger_player_entered_dungeon():
	emit_signal("on_player_entered_dungeon")

func trigger_player_got_torch():
	emit_signal("on_player_got_torch")

func trigger_item_picked_up(item):
	emit_signal("on_item_picked_up", item)

func trigger_item_dropped(item):
	emit_signal("on_item_dropped", item)

func trigger_player_activated_gate():
	emit_signal("on_player_activated_gate")

func trigger_player_activated_passage():
	emit_signal("on_player_activated_passage")

func trigger_player_entered_passage():
	emit_signal("on_player_entered_passage")

func trigger_player_entered_library():
	emit_signal("on_player_entered_library")
