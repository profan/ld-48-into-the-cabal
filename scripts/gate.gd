extends Spatial

var TWEEN_DURATION = 2.0

var open_offset_y = 10.6
var closed_offset_y = 3.9

signal on_gate_opened
signal on_gate_closed

onready var gate = get_node("library_gate")
onready var tween = get_node("tween")

func _ready():
	pass

func _tween_gate_to_offset(v):
	
	tween.stop_all()
	
	tween.interpolate_property(
		gate, "translation:y",
		gate.translation.y,
		v, TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	
	tween.start()
	

func open_gate():
	_tween_gate_to_offset(open_offset_y)
	yield(tween, "tween_completed")
	emit_signal("on_gate_opened")

func close_gate():
	_tween_gate_to_offset(closed_offset_y)
	yield(tween, "tween_completed")
	emit_signal("on_gate_closed")
