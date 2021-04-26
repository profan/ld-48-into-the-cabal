extends Spatial

const DungeonScene = preload("res://the_dungeon_scene.tscn")

var has_spawned_dungeons = false

func _ready():
	Game.connect("on_player_activated_passage", self, "_on_player_activated_passage")
	
	# DEBUGGEN FOR THE DUNGEON
	# Game.trigger_player_entered_library()
	# Game.trigger_player_activated_passage()
	# Game.trigger_player_entered_passage()

func _on_player_activated_passage():
	if not has_spawned_dungeons:
		var dungeon_instance = DungeonScene.instance()
		has_spawned_dungeons = true
		add_child(dungeon_instance)
