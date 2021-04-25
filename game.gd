extends Node

signal on_player_activated_gate
signal on_player_entered_library
signal on_player_activated_passage
signal on_player_entered_passage

var _has_player_entered_library = false
var _has_player_entered_passage = false

func _ready():
	pass

func has_player_entered_library() -> bool:
	return _has_player_entered_library

func has_player_entered_passage() -> bool:
	return _has_player_entered_passage

func trigger_player_activated_gate():
	emit_signal("on_player_activated_gate")

func trigger_player_activated_passage():
	emit_signal("on_player_activated_passage")

func trigger_player_entered_passage():
	emit_signal("on_player_entered_passage")

func trigger_player_entered_library():
	emit_signal("on_player_entered_library")
