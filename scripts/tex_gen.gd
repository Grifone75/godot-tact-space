extends MeshInstance3D

var tex: Texture2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	await RenderingServer.frame_post_draw 
	tex = $Text_generator.get_texture()
	self.get_active_material(0).set("albedo_texture", tex)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_tex(my_text):
	$Text_generator/Label.text = my_text
	await RenderingServer.frame_post_draw 
	return $Text_generator.get_texture()
