class_name Drone_manager extends Resource

var drone_list = []



func add(d):
	drone_list.push_back(d)


func set_distance(d):
	for el in drone_list:
		el.distance = d
	return self

func set_focus(f):
	for el in drone_list:
		el.focus = f
	return self

func destroy():
	for el in drone_list:
		el.destroy()
	drone_list = []
	return self
