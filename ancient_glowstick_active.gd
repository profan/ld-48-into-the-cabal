extends Spatial

var DEFAULT_GRAVITY = Vector3(0.0, 2.25, 0.0)

onready var particles = get_node("particles")

var particles_material: ParticlesMaterial
var current_velocity: Vector3 = Vector3.ZERO

func _ready():
	particles_material = particles.process_material as ParticlesMaterial

func _process(delta):
	particles_material.gravity = DEFAULT_GRAVITY + current_velocity

func set_view_velocity(v):
	current_velocity = v
