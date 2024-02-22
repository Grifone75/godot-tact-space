extends Node3D


func set_free():
	$NavPoint/Draw3D.default_color = "#417b6184"
	$NavPoint.redraw()
	
func set_taken():
	$NavPoint/Draw3D.default_color = "#f0963084"
	$NavPoint.redraw()
