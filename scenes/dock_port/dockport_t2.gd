@tool
extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	_close_arm()
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _close_arm():
	var tween = self.create_tween()
	tween.tween_property($shoulder2/arm2_1,"position",Vector3(0,7.433,0),3)
	tween.tween_property($shoulder2/arm2_1/arm2_2,"position",Vector3(0,0,-0.091),3)
	tween.tween_property($shoulder2/arm2_1/arm2_2/arm2_3,"position",Vector3(0,0,-0.146),3)
	
func _open_arm():
	var tween = self.create_tween()
	tween.tween_property($shoulder2/arm2_1,"position",Vector3(0,3.249,0),3)
	tween.tween_property($shoulder2/arm2_1/arm2_2,"position",Vector3(0,0,-4.49),3)
	tween.tween_property($shoulder2/arm2_1/arm2_2/arm2_3,"position",Vector3(0,0,-4.489),3)

