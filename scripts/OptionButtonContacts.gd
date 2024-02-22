extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_pressed():
	clear()
	for el in $/root/base.followed_vessel.pilot.contact_list:
		var el_id = el.get_instance_id()
		print(el, '--', el_id)
		add_item(el.name, el_id)
		var idx = get_item_index(el_id)

		if el.has_node("VesselController"):
			set_item_metadata(idx, el.rb)
		else:
			set_item_metadata(idx, el)
	
	
