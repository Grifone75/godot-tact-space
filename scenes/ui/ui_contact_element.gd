extends Button

var connected_node : Contact

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if connected_node:
		$HBoxContainer/name.text = connected_node.contact.get_linked_object().name
		$HBoxContainer/class.text = connected_node.contact_type
		$HBoxContainer/distance.text = Metric.dst2str(connected_node.get_distance.call())

func setup(element_data):
	connected_node = element_data
	


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if (event.button_index == 1) and event.pressed:
			print(connected_node.contact.get_linked_object().name) # Replace with function body.
			$/root/base.followed_vessel_change_nav_target(connected_node.contact)
	#print(event)
	pass # Replace with function body.
