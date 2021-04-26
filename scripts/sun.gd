extends DirectionalLight

var tween: Tween

var TWEEN_DURATION = 2.0

func _ready():
	tween = Tween.new()
	Game.connect("on_player_entered_library", self, "_on_player_entered_library")
	tween.connect("tween_all_completed", self, "_on_all_tweens_finished", [], CONNECT_ONESHOT)
	add_child(tween)

func _on_all_tweens_finished():
	visible = false

func _on_player_entered_library():
	
	tween.interpolate_property(
		self, "light_energy",
		light_energy, 0.0,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	
	tween.interpolate_property(
		self, "light_indirect_energy",
		light_indirect_energy, 0.0,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	
	tween.start()
