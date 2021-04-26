extends Spatial

func _ready():
	Game.trigger_player_activated_gate()
	Game.trigger_player_entered_library()
	Game.trigger_player_activated_passage()
	Game.trigger_player_entered_passage()
