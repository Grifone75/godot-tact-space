extends Node

var parking_points = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var ref = get_parent().rb
	for dx in range(-2,2):
		for dy in range(-2,2):
			var pos = load("res://scenes/parkpoint.tscn").instantiate()
			ref.add_child(pos)
			pos.name = "parking"
			pos.remove_from_group("local_objects")
			pos.global_transform.origin = ref.global_position + Vector3(dx*15,dy*15,50)
			parking_points[pos] = null


func get_parking_point():
	var free_spot = parking_points.keys().filter(func(x): return (parking_points[x] == null))[0]
	parking_points[free_spot] = 'taken'
	return free_spot

