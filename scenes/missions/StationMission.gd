class_name StationMission extends EmptyMission


func play():
	pilot.mission_details = 'station autostabilizing'
	while true: #test to have ships cycling to various stations
		pilot.set_translation_mode('stop').set_orientation_mode('face_fixed')
		await get_tree().create_timer(5.).timeout
	
