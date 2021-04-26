extends ColorRect

var FADE_TIME = 0.35

var tween: Tween

func _ready():
	Game.connect("on_fade_requested", self, "_on_fade_requested")
	tween = Tween.new()
	add_child(tween)

func _on_fade_requested(t=FADE_TIME):
	
	tween.interpolate_property(
		self, "color:a", color.a, 1.0, t,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT
	)
	
	tween.interpolate_property(
		self, "color:a", 1.0, 0.0, t,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT,
		t
	)
	
	tween.start()
