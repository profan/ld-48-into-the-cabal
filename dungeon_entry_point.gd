extends Spatial

onready var fwd = get_node("dungeon-module-choice")
onready var lft = get_node("dungeon-module-choice2")
onready var rht = get_node("dungeon-module-choice3")

onready var start_area = get_node("module-4-way/start_area")

func _ready():
	
	start_area.connect("body_entered", self ,"_on_body_entered_start_area")
	
	Game.connect("on_dungeon_failed_from_dir", self, "_on_dungeon_failed_from_direction")
	Game.connect("on_dungeon_reset", self, "_on_dungeon_reset")
	
	Game.register_direction_entry(Game.Direction.Forward, fwd)
	Game.register_direction_entry(Game.Direction.Left, lft)
	Game.register_direction_entry(Game.Direction.Right, rht)

func _on_body_entered_start_area(body):
	if body.name == "player" and Game.is_returning_to_start():
		Game.set_returning_to_start(false)

func _on_dungeon_reset():
	fwd.show_this_again()
	lft.show_this_again()
	rht.show_this_again()

func _on_dungeon_failed_from_direction(dir):
	
	if dir == Game.Direction.Forward:
		fwd.hide_this_for_now()
		lft.show_this_again()
		rht.show_this_again()
	elif dir == Game.Direction.Left:
		fwd.show_this_again()
		rht.hide_this_for_now()
		lft.show_this_again()
	elif dir == Game.Direction.Right:
		fwd.show_this_again()
		rht.show_this_again()
		lft.hide_this_for_now()
	
	fwd.reset_this()
	lft.reset_this()
	rht.reset_this()
	
