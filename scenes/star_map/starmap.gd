@tool
extends GraphEdit



func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PackedVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)

# Called when the node enters the scene tree for the first time.
func _draw():
	for i in range(10):
		draw_circle_arc(Vector2(100*i,100*i),200, 25,160,Color("yellow"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
