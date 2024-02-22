extends Node

var parking_points = {}
var docking_ports = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	#check how many docking ports are available
	var docks = get_parent().functionals.get("dockports")
	for el in docks:
		el.switch_reference_visual(true)
		docking_ports[el] = "free"


	var ref = get_parent().rb
	for dx in range(-2,2):
		for dy in range(-2,2):
			var pos = load("res://scenes/parkpoint.tscn").instantiate()
			ref.add_child(pos)
			pos.name = "parking"
			pos.get_node("origin_shiftable").set_active(false)
			pos.global_transform.origin = ref.global_position + Vector3(dx*15,dy*15,50)
			parking_points[pos] = "free"


func get_parking_point():
	var free_spots = parking_points.keys().filter(func(x): return (parking_points[x] == "free"))
	if len(free_spots) > 0:
		var free_spot = free_spots.pick_random()
		parking_points[free_spot] = 'taken'
		free_spot.set_taken()
		return free_spot
	else:
		return null


func release_parking_point(parking_point):
	parking_points[parking_point] = "free"
	parking_point.set_free()


func get_docking_port():
	var free_docks = docking_ports.keys().filter(func(x): return (docking_ports[x] == "free"))
	if len(free_docks) > 0:
		var free_dock = free_docks.pick_random()
		docking_ports[free_dock] = 'taken'
		free_dock.set_taken()
		return free_dock
	else:
		return null


func release_docking_port(docking_port):
	docking_ports[docking_port] = "free"
	docking_port.set_free()

