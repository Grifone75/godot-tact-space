extends Node2D
"""
this is a most generic marker for hud capable of projecting a 3d pos on the screen.
more configuration to come
"""
@export var marked_node: Node3D
var transform_function: Callable = Callable()
# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = get_parent().name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pos3d
	if not transform_function.is_valid():
		pos3d = marked_node.global_position if marked_node else get_parent().global_position
	else:
		pos3d = transform_function.call()
	#if $/root/base:
	self.show()
	if (get_viewport().get_camera_3d().is_position_behind(pos3d)):
		self.hide()
	else:
		self.show()
		var screen_pos = get_viewport().get_camera_3d().unproject_position(pos3d)
		self.position = screen_pos
