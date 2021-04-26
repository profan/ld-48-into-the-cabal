extends Node

const Music = preload("res://raw/music/background_trimmed.wav")

signal on_fade_requested
signal on_text_print_requested(text)

# pre dungeon

signal on_player_activated_gate
signal on_player_entered_library
signal on_player_activated_passage
signal on_player_entered_passage
signal on_player_got_torch
signal on_player_activated_dungeon
signal on_player_entered_dungeon
signal on_player_entered_throne_room

signal on_item_picked_up
signal on_item_dropped

var _has_player_entered_library = false
var _has_player_entered_passage = false
var _world_environment: WorldEnvironment = null

# dungeon
signal on_dungeon_success
signal on_dungeon_failed_from_dir(dir)
signal on_dungeon_step(dir)
signal on_dungeon_enter_four_way(which)
signal on_dungeon_reset

var _dungeon_progress = []
var _direction_entries = {}
var _dungeon_start_offset: Vector3 = Vector3.ZERO
var _is_returning_to_start = false
var _turn_counter = 0

var audio_player: AudioStreamPlayer
var tween: Tween

func _interpolate_volume(v):
	audio_player.volume_db = linear2db(v)

func _on_music_end():
	_fade_in_music()

func _fade_in_music():
	
	audio_player.play()
	
	tween.interpolate_method(
		self, "_interpolate_volume",
		0.0, 0.3, 4.0, Tween.TRANS_CUBIC,
		Tween.EASE_IN_OUT
	)
	tween.start()

func _ready():
	
	tween = Tween.new()
	add_child(tween)
	
	audio_player = AudioStreamPlayer.new()
	var volume_db = linear2db(0.3)
	audio_player.volume_db = 0.0
	audio_player.stream = Music
	add_child(audio_player)
	
	# audio_player.connect("finished", self, "_on_music_end")
	
enum Direction {
	Forward,
	Left,
	Right
}

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("fullscreen"):
			OS.window_fullscreen = !OS.window_fullscreen

func request_text_print(text):
	emit_signal("on_text_print_requested", text)

func has_won_dungeon() -> bool:
	var total_angle = 0
	for dir in _dungeon_progress:
		total_angle += get_dir_turnz_angle(dir)
	return abs(total_angle) >= 360

func has_failed_dungeon() -> bool:
	
	var last_dir = null
	for dir in _dungeon_progress:
		if last_dir != null and last_dir == dir:
			return true
		last_dir = dir
	
	return false

func request_fade(time=0.35):
	emit_signal("on_fade_requested", time)

func add_turn(dir):
	if dir == Direction.Left:
		_turn_counter = wrapi(_turn_counter - 1, 0, 4)
	elif dir == Direction.Right:
		_turn_counter = wrapi(_turn_counter + 1, 0, 4)

func last_dir_turnz_angle() -> int:
	if _dungeon_progress.size() > 1:
		return get_dir_turnz_angle(_dungeon_progress[_dungeon_progress.size() - 2])
	return 0

func get_dir_turnz_angle(dir) -> int:
	match dir:
		Direction.Left:
			return -90
		Direction.Right:
			return 90
		_:
			return 0

func get_turnz() -> int:
	return _turn_counter

func get_turnz_angle() -> int:
	match _turn_counter:
		0: return 0
		1: return 90
		2: return 180
		3: return 270
		_: return 0

func set_returning_to_start(v):
	_is_returning_to_start = v

func is_returning_to_start() -> bool:
	return _is_returning_to_start

func get_dungeon_start_offset() -> Vector3:
	return _dungeon_start_offset

func register_dungeon_start_offset(offset):
	_dungeon_start_offset = offset

func clear_dungeon_steps():
	_dungeon_progress.clear()

func register_dungeon_step(dir):
	_dungeon_progress.append(dir)

func register_direction_entry(dir, obj):
	_direction_entries[dir] = obj

func trigger_dungeon_reset():
	clear_dungeon_steps()
	_is_returning_to_start = true
	emit_signal("on_dungeon_reset")

func trigger_dungeon_fail_from_dir(dir):
	emit_signal("on_dungeon_failed_from_dir", dir)

func trigger_dungeon_enter_four_way(which):
	emit_signal("on_dungeon_enter_four_way", which)

func trigger_next_dungeon_section(dir):
	register_dungeon_step(dir)
	add_turn(dir)

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
	_fade_in_music()
	request_text_print("... this gate has not seen use for a long time")
	emit_signal("on_player_activated_gate")

func trigger_player_activated_passage():
	request_text_print("..?")
	emit_signal("on_player_activated_passage")

func trigger_player_entered_passage():
	emit_signal("on_player_entered_passage")

func trigger_player_entered_library():
	request_text_print(" - it is said only one book remains, it will lead us to the passage")
	request_text_print("(press e to pick up the book)")
	emit_signal("on_player_entered_library")
