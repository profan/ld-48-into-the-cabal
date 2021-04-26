extends Spatial

export var is_first_module = false
onready var trigger_close_door = get_node("module-4-way/trigger")

onready var forward = get_node("dungeon-module-choice-fwd")
onready var left = get_node("dungeon-module-choice-left")
onready var right = get_node("dungeon-module-choice-right")

var current_number = 1
var has_closed_door_behind_player = false

func _ready():
	trigger_close_door.connect("body_entered", self, "_on_body_entered_four_way")
	Game.connect("on_dungeon_enter_four_way", self, "_on_player_entered_four_way")
	Game.connect("on_dungeon_reset", self, "_on_dungeon_reset")
	
	if is_first_module:
		forward.is_first_step = true
		left.is_first_step = true
		right.is_first_step = true

func _on_dungeon_reset():
	queue_free()

func _on_player_entered_four_way(which):
	if which != self and not which.is_first_module:
		current_number -= 1
		if current_number < 0:
			queue_free()

func _on_body_entered_four_way(body):
	if body.name == "player" and not has_closed_door_behind_player:
		has_closed_door_behind_player = true
		Game.trigger_dungeon_enter_four_way(self)
