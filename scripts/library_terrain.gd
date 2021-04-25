extends Spatial

onready var collider = get_node("ground/static_collision")
onready var collider_shape = get_node("ground/static_collision/shape0")

func _ready():
	Game.connect("on_player_entered_library", self, "_on_player_enters_passage")

func _on_player_enters_passage():
	collider_shape.disabled = true
	visible = false
