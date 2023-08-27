class_name Base_mission extends Resource


var linked_targeting_mgr = null
var linked_nav_metrics = null
var linked_pilot = null

func _init(calling_pilot):
	linked_pilot = calling_pilot
	linked_nav_metrics = calling_pilot.nav_metrics
	linked_targeting_mgr = calling_pilot.targeting_manager
	


func play():
	_play_mission()



func _play_mission():
	await linked_pilot.get_tree().create_timer(2.).timeout
	var counter = 3
	while counter > 0:
		if (counter == 3) or linked_nav_metrics.l_translation_to_target.length() < 10:
			var t1 = linked_pilot.get_tree().get_nodes_in_group("navpoints").pick_random() #to be replaced with picking target from the pilot contact list
			linked_pilot.update_navtarget(t1)
			linked_pilot.nav_method = [linked_pilot._apply_orientation,linked_pilot._apply_approach2]
			linked_pilot.nav_method_name = 'mission1'
			counter -= 1
		await linked_pilot.get_tree().create_timer(2.).timeout
	linked_pilot.nav_method = [func(): linked_pilot._apply_orientation(Vector3.AXIS_X), linked_pilot._kill_all_velocity]
	linked_pilot.nav_method_name = 'mission1 ended - stabilize'


	

