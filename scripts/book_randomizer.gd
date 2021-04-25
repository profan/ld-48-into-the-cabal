extends Spatial

# onready var rigid_body = get_node("book")
# onready var mesh_instance = get_node("book/mesh")

onready var mesh_instance = get_node("book")

const possible_colours = [
	
	Color("80382E"), # reddish
	Color("202222"), # blackish
	
	Color("688028"), # greenish
	Color("1C6280"), # blueish
	
	Color("7A3180"), # purpleish
	Color("802B3A"), # yellow-greenish
	
]

func set_edge_colour(new_color: Color):
	var mesh = mesh_instance.get_mesh()
	var material = mesh.surface_get_material(2).duplicate()
	material.albedo_color = new_color
	mesh_instance.set_surface_material(2, material)

func set_main_colour(new_color: Color):
	var mesh = mesh_instance.get_mesh()
	var material = mesh.surface_get_material(0).duplicate()
	material.albedo_color = new_color
	mesh_instance.set_surface_material(0, material)

func _ready():
	
	# we need this lol, only if rigidbody though
	# rigid_body.sleeping = true
	
	var random_edge_colour_idx = rand_range(0, possible_colours.size())
	var random_main_colour_idx = rand_range(0, possible_colours.size())
	
	var random_edge_colour = possible_colours[random_edge_colour_idx]
	var random_main_colour = possible_colours[random_main_colour_idx]
	
	set_edge_colour(random_edge_colour.darkened(0.25))
	set_main_colour(random_edge_colour.darkened(0.85))
	
