extends Spatial

var TWEEN_DURATION = 2.0

onready var anim_player = get_node("anim_player")
onready var trigger_activate_area = get_node("trigger")
onready var trigger_close_area = get_node("trigger_close")

onready var triggered_light = get_node("trigger/trigger_light")

var has_triggered = false
var has_triggered_close = false

var book_is_inside_trigger = true

var tween: Tween

func _ready():
	tween = Tween.new()
	trigger_activate_area.connect("body_entered", self, "_on_body_enter_activate_area")
	trigger_activate_area.connect("body_exited", self, "_on_body_exit_activate_area")
	trigger_close_area.connect("body_entered", self, "_on_body_entered_close_area")
	tween.connect("tween_completed", self, "_on_tween_fade_completed")
	add_child(tween)
	
	# set up light
	triggered_light.light_energy = 0.0

func _on_tween_fade_completed(obj, key):
	triggered_light.visible = triggered_light.light_energy > 0.1

func _fade_light_to(v):
	tween.interpolate_property(
		triggered_light, "light_energy",
		triggered_light.light_energy, v,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	tween.start()

func _fade_in_light():
	tween.stop_all()
	triggered_light.visible = true
	_fade_light_to(1.0)

func _fade_out_light():
	tween.stop_all()
	_fade_light_to(0.0)

func _on_item_dropped(item):
	if item.name == "the_book_interactable" and book_is_inside_trigger and not has_triggered:
		anim_player.play("open_the_pathway")
		Game.trigger_player_activated_passage()
		has_triggered = true
		_fade_in_light()

func _on_body_enter_activate_area(body):
	if body.name == "the_book_interactable":
		book_is_inside_trigger = true
		_on_item_dropped(body)

func _on_body_exit_activate_area(body):
	if body.name == "the_book_interactable" and has_triggered:
		book_is_inside_trigger = false
		anim_player.play_backwards("open_the_pathway")
		has_triggered = false
		_fade_out_light()

func _on_body_entered_close_area(body):
	if body.name == "player" and not has_triggered_close:
		anim_player.play_backwards("open_the_pathway")
		Game.trigger_player_entered_passage()
		has_triggered_close = true
		_fade_out_light()
