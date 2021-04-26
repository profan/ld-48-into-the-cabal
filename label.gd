extends Label

var FADE_TIME = 2.0
var PRINT_TIME = 1.0

var _text_queued = []

var _print_timer = 0.0

var tween: Tween
var is_active: bool = false

func _ready():
	Game.connect("on_text_print_requested", self, "_on_text_print_requested")
	tween = Tween.new()
	add_child(tween)

func _on_text_print_requested(text):
	
	# no dupes
	if _text_queued.size() > 0:
		if text == _text_queued.back():
			return
		
	_text_queued.append(text)

func _process(delta):
	
	_print_timer -= delta
	if _text_queued.size() > 0 and _print_timer <= 0.0 and not is_active:
		
		is_active = true
		text = _text_queued.front()
		_text_queued.pop_front()
		
		tween.interpolate_property(
			self, "modulate:a", modulate.a, 1.0,
			FADE_TIME, Tween.TRANS_QUAD,
			Tween.EASE_IN_OUT
		)
		tween.start()
		yield(tween, "tween_all_completed")
		
		tween.interpolate_property(
			self, "modulate:a", modulate.a, 0.0,
			FADE_TIME, Tween.TRANS_QUAD,
			Tween.EASE_IN_OUT
		)
		tween.start()
		yield(tween, "tween_all_completed")
		is_active = false
		
		_print_timer = PRINT_TIME
