extends Decal

@export var tex:Texture2D
# Called when the node enters the scene tree for the first time.
func _ready():
	#await RenderingServer.frame_post_draw 
	
	#await get_tree().create_timer(1.).timeout
	if $/root/base:
		tex = await $/root/base/Tex_gen.get_tex("initial")
		self.texture_albedo = tex
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_text(text):
	if $/root/base:
		tex = await $/root/base/Tex_gen.get_tex(text)
		self.texture_albedo = tex
	
