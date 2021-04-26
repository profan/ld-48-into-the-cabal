extends Spatial

onready var collider = get_node("ground/static_collision")
onready var collider_shape = get_node("ground/static_collision/shape0")

func _ready():
	Game.connect("on_player_activated_passage", self, "_on_player_activated_passage")

func _on_player_activated_passage():
	collider_shape.disabled = true
	visible = false
