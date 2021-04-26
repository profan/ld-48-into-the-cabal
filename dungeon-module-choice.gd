extends Spatial

var DungeonChoicePrefab = load("res://dungeon-module-four-way.tscn")

export var is_first_step = false
export(Game.Direction) var direction = Game.Direction.Forward

onready var trigger_area = get_node("trigger")
onready var entry_door = get_node("gate_entry")
onready var exit_door = get_node("gate_exit")

var spawn_offset: Vector3 = Vector3(-10.0, 0.0, 0.275)
var spawn_rot: Vector3 = Vector3(0.0, 0.0, 0.0)

var initial_offset_y = 0.0

var offset_y = -9

var was_offset = false
var current_number = 1
var has_triggered = false
var has_spawned_choices = false
var current_player: KinematicBody = null

func _ready():
	trigger_area.connect("body_entered", self, "_on_body_entered_area")
	entry_door.connect("on_gate_closed", self, "_on_entry_door_closed")
	exit_door.connect("on_gate_closed", self, "_on_exit_door_closed")
	Game.connect("on_dungeon_enter_four_way", self, "_on_player_entered_four_way")
	initial_offset_y = translation.y

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
	if body.name == "player" and not has_triggered:
		entry_door.close_gate()
		# FUDGEN JAM CODE
		current_player = body

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
	
	_spawn_the_choices()
	exit_door.open_gate()

func _on_exit_door_opened():
	pass

func _on_exit_door_closed():
	pass
