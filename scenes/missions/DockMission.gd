extends EmptyMission


func play():
	pilot.mission_details = 'initiating'

	while true: #test to have ships cycling to various stations
		await get_tree().create_timer(2.).timeout
		var station = pilot.get_tree().get_nodes_in_group("stations").pick_random()
		if station and station.has_node("traffic_manager"):
			var parking = station.get_node("traffic_manager").get_parking_point()
			if parking:
				var station_rb = station.rb 
				pilot.mission_details = 'park target set to ' + station.name + ' ' + parking.name
				pilot.update_navtarget(parking)
				pilot.nav_metrics.set_approach_distance(0)
				pilot.set_translation_mode('approach').set_orientation_mode('face_target')
				while nav_metrics.l_translation_to_target.length() > 10:
					pilot.mission_details = 'approaching ' + station.name
					await get_tree().create_timer(2.).timeout
				pilot.set_translation_mode('axial').set_orientation_mode('face_fixed')
				pilot.mission_details = 'refining ' + station.name
				while nav_metrics.l_translation_to_target.length() > 1:
					await get_tree().create_timer(2.).timeout
				await get_tree().create_timer(5.).timeout
				pilot.set_translation_mode('stop').set_orientation_mode('face_fixed')
				pilot.mission_details = 'mission waiting to dock - stabilize'
				var res = station.request_docking()
				print(res)
				var dock = station.get_node("traffic_manager").get_docking_port()
				
				if dock:
					var align_point = dock.get_alignment_point()
					pilot.nav_metrics.set_approach_distance(0)
					pilot.mission_details = 'aligning to ' + station.name + ' ' + parking.name
					pilot.update_navtarget(align_point)
					var target_dock_ref = dock.get_dockport_reference()
					if pilot.set_docking_mode(target_dock_ref):
						#TODO : when we use a local rototraslation node, also the nav metrics distances should take it into account. So we need to rewrite the
						# way nav metrics, ai pilot interacts when setting / clearing the localrototrans node.
						mplayer.critical_timer(10)
						while nav_metrics.l_translation_to_target.length() > 0.5:
							await get_tree().create_timer(2.).timeout
						pilot.update_navtarget(target_dock_ref)
						while nav_metrics.l_translation_to_target.length() > 0.1:
							await get_tree().create_timer(2.).timeout

						await get_tree().create_timer(2.).timeout
						pilot.clear_docking_mode()
					station.get_node("traffic_manager").release_docking_port(dock)

				# now free dockport as we are cycling this mission. This is just temporary
				station.get_node("traffic_manager").release_parking_point(parking)
			else:
				await get_tree().create_timer(5.).timeout

	
func outro():
	pilot.clear_docking_mode()
	pilot.set_translation_mode('idle').set_orientation_mode('idle')
