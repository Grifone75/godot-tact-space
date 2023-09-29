class_name Base_mission extends Resource


var linked_targeting_mgr = null
var linked_nav_metrics = null
var linked_pilot = null
var status = "idle generic"
@export var is_playing:bool

func _init(calling_pilot):
	linked_pilot = calling_pilot
	linked_nav_metrics = calling_pilot.nav_metrics
	linked_targeting_mgr = calling_pilot.targeting_manager
	is_playing = false
	


func play():
	is_playing = true
	print("set playing to :", is_playing)
	_play_mission()
	is_playing = false


func _play_mission():
	await linked_pilot.get_tree().create_timer(2.).timeout
	var max_cycles = 3
	var counter = max_cycles
	while counter > 0:
		if (counter == max_cycles) or linked_nav_metrics.l_translation_to_target.length() < 10:
			var t1
			if counter != 1:
				t1 = linked_pilot.get_tree().get_nodes_in_group("navpoints").pick_random() #to be replaced with picking target from the pilot contact list
			else:
				t1 = linked_pilot.get_tree().get_nodes_in_group("stations").pick_random().rb 
				linked_pilot.nav_metrics.set_approach_distance(50)
			linked_pilot.update_navtarget(t1)
			linked_pilot.set_translation_mode('approach').set_orientation_mode('face_target')
			linked_pilot.mission_details = 'mission1'
			counter -= 1
		await linked_pilot.get_tree().create_timer(2.).timeout
	linked_pilot.mission_details = 'mission1 last step'
	while linked_nav_metrics.l_translation_to_target.length() > 50:
		await linked_pilot.get_tree().create_timer(2.).timeout	
		linked_pilot.set_translation_mode('stop').set_orientation_mode('face_fixed')
	linked_pilot.mission_details = 'mission1 ended - stabilize'


	

