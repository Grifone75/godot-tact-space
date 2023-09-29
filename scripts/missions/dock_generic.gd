class_name Dock_generic extends Base_mission


func _play_mission():
	linked_pilot.mission_details = 'initiating'
	while true: #test to have ships cycling to various stations
		await linked_pilot.get_tree().create_timer(2.).timeout
		var station = linked_pilot.get_tree().get_nodes_in_group("stations").pick_random()
		if station and station.get_node("traffic_manager"):
			var parking = station.get_node("traffic_manager").get_parking_point()
			var station_rb = station.rb 
			linked_pilot.mission_details = 'park target set to ' + station.name + ' ' + parking.name
			linked_pilot.update_navtarget(parking)
			linked_pilot.nav_metrics.set_approach_distance(0)
			linked_pilot.set_translation_mode('approach').set_orientation_mode('face_target')
			while linked_nav_metrics.l_translation_to_target.length() > 10:
				linked_pilot.mission_details = 'approaching ' + station.name
				await linked_pilot.get_tree().create_timer(2.).timeout	
			linked_pilot.set_translation_mode('axial').set_orientation_mode('face_fixed')
			linked_pilot.mission_details = 'refining ' + station.name
			while linked_nav_metrics.l_translation_to_target.length() > 1:
				await linked_pilot.get_tree().create_timer(2.).timeout	
			await linked_pilot.get_tree().create_timer(5.).timeout	
			linked_pilot.set_translation_mode('stop').set_orientation_mode('face_fixed')
			linked_pilot.mission_details = 'mission waiting to dock - stabilize'
			var res = station.request_docking()
			print(res)
	return Base_mission

