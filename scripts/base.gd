extends Node3D

var cam_tracked = null
var followed_vessel
var moving_origin: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#SubViewportContainer/
	$SubViewportContainer/SubViewport_objects/cam_track.tracked_updated.connect(func(x) : cam_tracked = x)
	_delayed_init()
	

func _delayed_init():
	await get_tree().create_timer(1.5).timeout
	followed_vessel = get_tree().get_nodes_in_group("vessels").pick_random()
	_update_followed_relationships()

func _update_followed_relationships():
	$SubViewportContainer/SubViewport_objects/cam_track.update_tracked(
		followed_vessel.get_node("VesselController/RigidBody3D")
	)
	

func _origin_shift():
	moving_origin = true
	var shift = $SubViewportContainer/SubViewport_objects/cam_track.global_position
	print("*** calling OShift, delta: ",shift)
	for obj in get_tree().get_nodes_in_group("local_objects"):
		if obj.is_in_group("vessels"):
			obj.get_node("VesselController/RigidBody3D").global_position -= shift
		else:
			obj.global_position -= shift
	for obj in get_tree().get_nodes_in_group("far_objects"):
		obj.global_position -= shift/10000.0
	$SubViewportContainer/SubViewport_objects/cam_track.reset_origin()
	moving_origin = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var _time = Time.get_ticks_msec() / 1000.0
	if ($SubViewportContainer/SubViewport_objects/cam_track.global_position.length() > 1000) and !moving_origin:
		_origin_shift()

	# DebugDraw.set_text("Time", _time)
	# DebugDraw.set_text("Frames drawn", Engine.get_frames_drawn())
	# DebugDraw.set_text("FPS", Engine.get_frames_per_second())
	# DebugDraw.set_text("delta", delta)



func _on_button_pressed():
	var nav = get_tree().get_nodes_in_group("navpoints").pick_random()
	followed_vessel.get_node("AIPilot").update_navtarget(nav)



var current_index = 0
func _on_button_change_ship_pressed():
	_on_direct_control_button_toggled(false) #to be sure we restore ai pilot when changing vessel
	get_node("/root/base/SubViewportContainer/FlowContainer/DirectControlButton").button_pressed = false
	#followed_vessel = get_tree().get_nodes_in_group("vessels").pick_random()
	if current_index >= len(get_tree().get_nodes_in_group("vessels")):
		current_index = 0
	followed_vessel = get_tree().get_nodes_in_group("vessels")[current_index]
	current_index += 1
	_update_followed_relationships()


func _on_nav_mode_list_item_selected(index):
	followed_vessel.get_node("AIPilot").update_navmode(index)


func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	followed_vessel.get_node("AIPilot").update_navmode(index)


func _on_direct_control_button_toggled(button_pressed):
	if button_pressed:
		if followed_vessel:
			followed_vessel.get_node("AIPilot").torque_input.disconnect(followed_vessel.get_node("VesselController").update_control_torque)
			followed_vessel.get_node("AIPilot").force_input.disconnect(followed_vessel.get_node("VesselController").update_control_force)
			
			$PlayerInputHandler.force_input.connect(followed_vessel.get_node("VesselController").update_control_force)
			$PlayerInputHandler.torque_input.connect(followed_vessel.get_node("VesselController").update_control_torque)
	else:
		if followed_vessel:
			$PlayerInputHandler.force_input.disconnect(followed_vessel.get_node("VesselController").update_control_force)
			$PlayerInputHandler.torque_input.disconnect(followed_vessel.get_node("VesselController").update_control_torque)
			followed_vessel.get_node("AIPilot").torque_input.connect(followed_vessel.get_node("VesselController").update_control_torque)
			followed_vessel.get_node("AIPilot").force_input.connect(followed_vessel.get_node("VesselController").update_control_force)
		


func _on_aggressive_mode_toggled(button_pressed):
	if followed_vessel:
		followed_vessel.get_node("VesselController").set_aggressive(button_pressed)
