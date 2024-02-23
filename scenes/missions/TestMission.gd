extends EmptyMission

func play():
	print("mission ok for ",pilot.name)


	await get_tree().create_timer(2.).timeout
	var max_cycles = 3
	var counter = max_cycles
	while counter > 0:
		if (counter == max_cycles) or nav_metrics.l_translation_to_target.length() < 10:
			var t1
			if counter != 1:
				t1 = pilot.get_tree().get_nodes_in_group("navpoints").pick_random() #to be replaced with picking target from the pilot contact list
			else:
				t1 = pilot.get_tree().get_nodes_in_group("stations").pick_random()
				pilot.nav_metrics.set_approach_distance(50)
			pilot.update_navtarget(t1.get_node("contactable"))
			pilot.set_translation_mode('approach').set_orientation_mode('face_target')
			pilot.mission_details = 'mission1'
			counter -= 1
		await get_tree().create_timer(2.).timeout
	pilot.mission_details = 'mission1 last step'
	while nav_metrics.l_translation_to_target.length() > 50:
		await get_tree().create_timer(2.).timeout
		pilot.set_translation_mode('stop').set_orientation_mode('face_fixed')
	pilot.mission_details = 'mission1 ended - stabilize'
