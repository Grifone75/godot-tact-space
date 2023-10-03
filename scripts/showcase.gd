extends Node3D

var ship
var faction
# Called when the node enters the scene tree for the first time.
func _ready():
	set_random_new_faction()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ship and ship.rb:
		ship.rb.rotate(Vector3.UP,0.01)
	

func _on_button_pressed(type:String):
	if ship:
		ship.queue_free()
	if type == 'station':
		_large_setup()
		ship = load("res://scenes/station.tscn").instantiate()
	else:
		_small_setup()
		ship = load("res://scenes/vessel.tscn").instantiate()
	$holder.add_child(ship)
	ship.materialize(faction)
	$ship_display/blueprint.clear()
	$ship_display/blueprint.append_text(_prettify_blueprint(ship.blueprint))

func _stringifier(str:String):
	if str.contains("attach_m"):
		return(">>")
	if (str.contains("rcs") or str.contains("engine")):
		return '[color=FFD700]'+str+'[/color]'
	if (str.contains("turret") or str.contains("gun")):
		return '[color=FF4500]'+str+'[/color]'
	else: return '[color=48D1CC]'+str+'[/color]'

func _prettify_blueprint(bp,tabs:String = ""):
	var part_string = ""
	for k in bp.keys():
		part_string += tabs + " - " + _stringifier(k)+"\n"+_prettify_blueprint(bp[k],tabs+"\t")
	return part_string
	


func _large_setup():
	var tween = self.create_tween()
	tween.tween_property($cam_holder,"global_position",Vector3(0,0,50),1)
	tween.parallel().tween_property($spot2,"position",Vector3(24,16,16),1)
	tween.parallel().tween_property($spot2,"range",200,1)
	tween.parallel().tween_property($spot1,"position",Vector3(-22,11,18),1)
	tween.parallel().tween_property($spot1,"range",200,1)
	tween.parallel().tween_property($spot1,"light_energy",6,1)
	tween.parallel().tween_property($spot2,"light_energy",2,1)
	
func _small_setup():
	var tween = self.create_tween()
	tween.tween_property($cam_holder,"global_position",Vector3(0,0,8),1)
	tween.parallel().tween_property($spot2,"position",Vector3(7,4,6),1)
	tween.parallel().tween_property($spot2,"range",20,1)
	tween.parallel().tween_property($spot1,"position",Vector3(-6,2.5,4),1)
	tween.parallel().tween_property($spot1,"range",30,1)
	tween.parallel().tween_property($spot1,"light_energy",3,1)
	tween.parallel().tween_property($spot2,"light_energy",1,1)
	
func set_random_new_faction():
	faction = Faction.new()
	$faction_display/main_col.color = faction.main_color
	$faction_display/second_col.color = faction.color_complement
	$faction_display/util_col.color = faction.color_utility
	
func test_stuff():
	ship.dematerialize()
