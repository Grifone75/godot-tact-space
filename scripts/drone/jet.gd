extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_burn(val):
	var main_scale = clampf(val,0.0,1.0)
	var side_scale = clampf(val+.5,0.0,1.0)
	self.scale = Vector3(main_scale,side_scale,side_scale)
	if val < 0.09:
		self.visible = false
	if val > 0.1:
		self.visible = true
