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
	tween.tween_property($dock_port/shoulder/shjoint0,"rotation",Vector3(0,0,0),3)
	tween.parallel().tween_property($dock_port/shoulder/shjoint0/arm1/eljoint1,"rotation", Vector3(PI/2,0,0), 3)
	tween.parallel().tween_property($dock_port/shoulder/shjoint0/arm1/eljoint1/elbow/eljoint2,"rotation", Vector3(PI/2,0,0), 3)
	
func _open_arm():
	var tween = self.create_tween()
	tween.tween_property($dock_port/shoulder/shjoint0,"rotation",Vector3(PI/2,0,0),3)
	tween.parallel().tween_property($dock_port/shoulder/shjoint0/arm1/eljoint1,"rotation", Vector3(0,0,0), 3)
	tween.parallel().tween_property($dock_port/shoulder/shjoint0/arm1/eljoint1/elbow/eljoint2,"rotation", Vector3(0,0,0), 3)
	
