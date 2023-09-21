class_name Dock_generic extends Base_mission


func _play_mission():
	linked_pilot.mission_details = 'initiating'
	await linked_pilot.get_tree().create_timer(2.).timeout
	var station = linked_pilot.get_tree().get_nodes_in_group("stations").pick_random()
	var station_rb = station.rb 
	linked_pilot.mission_details = 'dock target set to ' + station.name
	linked_pilot.update_navtarget(station_rb)
	linked_pilot.nav_metrics.set_orientation_mode(Nav_metrics.ORIENTATION_BASE.TO_TGT)
	linked_pilot.nav_metrics.set_approach_distance(50)
	linked_pilot.nav_method = [linked_pilot._apply_orientation,linked_pilot._apply_approach]
	while linked_nav_metrics.l_translation_to_target.length() > 50:
		linked_pilot.mission_details = 'approaching ' + station.name
		await linked_pilot.get_tree().create_timer(2.).timeout	
	linked_pilot.nav_method = [func(): linked_pilot._apply_orientation(Vector3.AXIS_X), linked_pilot._kill_all_velocity]
	linked_pilot.mission_details = 'mission waiting to dock - stabilize'
	var res = station.request_docking()
	print(res)
	return Base_mission

