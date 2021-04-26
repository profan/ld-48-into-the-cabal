extends WorldEnvironment

var TWEEN_DURATION = 2.0
var INSIDE_FOG_DEPTH_END = 100.0
var DARK_ENERGY = 0.25

var tween: Tween

func _ready():
	tween = Tween.new()
	Game.register_world_environment(self)
	Game.connect("on_player_activated_gate", self, "_on_player_activated_gate")
	Game.connect("on_player_entered_passage", self, "_on_player_entered_passage")
	add_child(tween)

func _change_ambient_energy(v):
	environment.ambient_light_sky_contribution = v
	environment.ambient_light_energy = v

func _on_player_activated_gate():
	
	tween.interpolate_property(
		environment, "fog_depth_end",
		environment.fog_depth_end, INSIDE_FOG_DEPTH_END,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	
	tween.start()

func _on_player_entered_passage():
	
	tween.interpolate_property(
		environment, "ambient_light_sky_contribution",
		environment.ambient_light_sky_contribution, DARK_ENERGY,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	
	tween.interpolate_property(
		environment, "ambient_light_energy",
		environment.ambient_light_energy, DARK_ENERGY,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	
	tween.start()