extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_values(val):
	$container/nav_data.clear()
	$container/mission_details.clear()
	$container/mission_details.add_text(val.get("mission"))
	for measure in val:
		$container/nav_data.add_text(measure + ": ")
		$container/nav_data.push_color(Color("yellow"))
		$container/nav_data.add_text(str(val[measure]) + "\n")
		$container/nav_data.pop()
		#txt += measure + ": " + str(val[measure]) + "\n"
	#self.text = txt
