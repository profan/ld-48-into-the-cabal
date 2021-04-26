extends Spatial

var DungeonChoicePrefab = load("res://dungeon-module-four-way.tscn")
var ThroneRoomPrefab = load("res://dungeon_throne_room.tscn")

export var is_first_step = false
export(Game.Direction) var direction = Game.Direction.Forward

onready var trigger_area = get_node("trigger")
onready var entry_door = get_node("gate_entry")
onready var exit_door = get_node("gate_exit")

var spawn_offset: Vector3 = Vector3(-10.0, 0.0, 0.275)
var spawn_rot: Vector3 = Vector3(0.0, 0.0, 0.0)

var initial_offset_y = 0.0

var offset_y = -9 * 2.0

var was_offset = false
var current_number = 1
var has_triggered = false
var has_spawned_choices = false

var last_player_parent: Spatial = null
var current_player: KinematicBody = null

func _ready():
	trigger_area.connect("body_entered", self, "_on_body_entered_area")
	trigger_area.connect("body_exited", self, "_on_body_exited_area")
	entry_door.connect("on_gate_closed", self, "_on_entry_door_closed")
	exit_door.connect("on_gate_closed", self, "_on_exit_door_closed")
	Game.connect("on_dungeon_enter_four_way", self, "_on_player_entered_four_way")
	initial_offset_y = translation.y

func hide_this_for_now():
	if not was_offset:
		var offset = Vector3(0.0, offset_y, 0.0)
		global_translate(offset)
		was_offset = true

func show_this_again():
	if was_offset:
		var offset = Vector3(0.0, offset_y, 0.0)
		global_translate(-offset)
		was_offset = false

func reset_this():
	current_number = 1
	entry_door.open_gate()
	exit_door.close_gate()
	has_spawned_choices = false
	has_triggered = false
	show_this_again()

func _on_player_entered_four_way(which):
	exit_door.close_gate()
	if which != self:
		current_number -= 1
		if current_number < 0:
			if is_first_step and was_offset:
				var offset = Vector3(0.0, offset_y, 0.0)
				global_translate(-offset)
				was_offset = false

func _spawn_the_choices():
	
	var new_choices = DungeonChoicePrefab.instance()
	
	var parent = get_parent()
	parent.add_child(new_choices)
	
	# var relative = four_way.translation;
	new_choices.rotation_degrees = rotation_degrees + spawn_rot
	new_choices.translation = translation + spawn_offset.rotated(Vector3.UP, new_choices.rotation.y)
	var old_global_transform = new_choices.global_transform
	
	parent.remove_child(new_choices)
	get_parent().get_parent().add_child(new_choices)
	new_choices.global_transform = old_global_transform
	
	has_spawned_choices = true
	

func _on_body_entered_area(body):
	if body.name == "player" and not has_triggered and not Game.is_returning_to_start():
		entry_door.close_gate()
		# FUDGEN JAM CODE
		current_player = body
		# reparent_player_to_us()

func _on_body_exited_area(body):
	if body.name == "player" and not has_triggered and not Game.is_returning_to_start():
		pass
		# return_player_to_parent()

func reparent_player_to_us():
	last_player_parent = current_player.get_parent()
	last_player_parent.remove_child(current_player)
	add_child(current_player)
	
func return_player_to_parent():
	if last_player_parent:
		last_player_parent.add_child(current_player)

func _on_entry_door_closed():
	
	if has_spawned_choices: return
	
	# if we're the first step, put the player a level below the actual level
	#   so we can just spawn prefabs willy nilly?
	
	if is_first_step:
		var offset = Vector3(0.0, offset_y, 0.0)
		current_player.global_translate(offset)
		global_translate(offset)
		was_offset = true
	
	Game.trigger_next_dungeon_section(direction)
	var failed = Game.has_failed_dungeon()
	var won = Game.has_won_dungeon()
	
	if won and not failed:
		
		exit_door.open_gate()
		
		var throne_room = ThroneRoomPrefab.instance()
		add_child(throne_room)
		throne_room.translation = Vector3(-22.002, 0, 0.271)
		
	elif failed:
		
		Game.trigger_dungeon_fail_from_dir(direction)
		
		# teleport us back to the start, also.. hide the section we overlap with :D
		var global_offset = Vector3.ZERO
		var new_global_rotation = Vector3.ZERO
		
		var cur_turnz_angle = Game.get_turnz_angle()
		
		match direction:
			Game.Direction.Forward:
				global_offset = Vector3(0.0, 0.0, 0.0)
				new_global_rotation = Vector3(0.0, 90.0, 0.0)
			Game.Direction.Left:
				global_offset = Vector3(7.14, 0.0, 6.85)
				new_global_rotation = Vector3(0.0, 0.0, 0.0)
			Game.Direction.Forward:
				global_offset = Vector3(0.0, 0.0, 0.0)
				new_global_rotation = Vector3(0.0, 90.0, 0.0)
			Game.Direction.Right:
				global_offset = Vector3(6.85, 0.0, -7.14)
				new_global_rotation = Vector3(0.0, 180.0, 0.0)
		
		if direction == Game.Direction.Forward:
			# global_offset = Vector3(-10.0, 0.0, 0.0).rotated(Vector3.UP, get_parent().rotation.y)
			pass
		elif direction == Game.Direction.Left:
			# global_offset = Vector3(7.14, 0.0, -6.85)
			# global_offset = Vector3(6.85, 0.0, 7.14)
			# new_global_rotation = Vector3(0.0, 90.0, 0.0)
			pass
		elif direction == Game.Direction.Right:
			# global_offset = Vector3(7.14, 0.0, -6.85)
			# new_global_rotation = Vector3(0.0, -90.0, 0.0)
			pass
		
		var old_global_origin = global_transform.origin
		var new_global_origin = Game.get_dungeon_start_offset()
		var player_offset_in_prefab = global_transform.origin - current_player.global_transform.origin
		
		var old_translation = translation
		global_transform.origin = new_global_origin + global_offset
		
		var old_rotation_y = get_parent().rotation_degrees.y
		rotation_degrees = -get_parent().rotation_degrees + new_global_rotation
		
		#var rotation_y_diff = old_rotation_y - rotation_degrees.y
		var rotation_y_diff = Game.last_dir_turnz_angle() - Game.get_dir_turnz_angle(direction)
		current_player.yaw = -new_global_rotation.y
		
		# var last_turnz_angle = Game.get_dir_turnz_angle
		var local_rotation_diff = rotation_degrees.y - new_global_rotation.y
		
		var height_offset_in_prefab = Vector3(0.0, player_offset_in_prefab.y, 0.0)
		current_player.global_transform.origin = new_global_origin - height_offset_in_prefab + global_offset
		
		entry_door.open_gate()
		exit_door.close_gate()
		
		Game.request_fade()
		Game.trigger_dungeon_reset()
		
	else:
		_spawn_the_choices()
		exit_door.open_gate()

func _on_exit_door_opened():
	pass

func _on_exit_door_closed():
	pass
