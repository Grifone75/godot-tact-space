extends Node3D

var cam_tracked = null #TODO not used?
var followed_vessel
var moving_origin: bool = false
@export var cam: Node3D = null
# Called when the node enters the scene tree for the first time.
func _ready():
	#DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	$SubViewportContainer/SubViewport_objects.connect("size_changed", _on_viewport_resize)
	cam.tracked_updated.connect(func(x) : cam_tracked = x)
	_delayed_init()

func _on_viewport_resize():
	print_debug("*** SIZE CHANGED")
	print_debug($SubViewportContainer/SubViewport_objects.size)
	$SubViewport_UI.size = $SubViewportContainer/SubViewport_objects.size
	

func _delayed_init():
	await get_tree().create_timer(1.5).timeout
	followed_vessel = get_tree().get_nodes_in_group("vessels").pick_random()
	_update_followed_relationships()

func _update_followed_relationships():
	cam.update_tracked(followed_vessel)
	$PlayerInputHandler.connect("special_commands", followed_vessel.pilot.process_command)
	

func _origin_shift():
	moving_origin = true
	var shift = cam.global_position
	print("*** calling OShift, delta: ",shift)
	for obj in get_tree().get_nodes_in_group("local_objects"):
		if obj.is_in_group("vessels"):
			obj.rb.global_position -= shift
			obj.smooth.teleport()
		elif obj.has_method("manage_origin_shift"):
			obj.manage_origin_shift(shift)
		else:
			obj.global_position -= shift
	for obj in get_tree().get_nodes_in_group("far_objects"):
		obj.global_position -= shift/10000.0
	#cam.reset_origin() #not necessary anymore as the camera is on a object which is already shifted
	moving_origin = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var _time = Time.get_ticks_msec() / 1000.0
	if (cam.global_position.length() > 1000) and !moving_origin:
		_origin_shift()

	# DebugDraw.set_text("Time", _time)
	# DebugDraw.set_text("Frames drawn", Engine.get_frames_drawn())
	# DebugDraw.set_text("FPS", Engine.get_frames_per_second())
	# DebugDraw.set_text("delta", delta)



func _on_button_pressed():
	var nav = get_tree().get_nodes_in_group("navpoints").pick_random()
	followed_vessel.pilot.update_navtarget(nav)



var current_index = 0
func _on_button_change_ship_pressed():
	_on_direct_control_button_toggled(false) #to be sure we restore ai pilot when changing vessel
	get_node("/root/base/VFlowContainer/DirectControlButton").button_pressed = false
	#followed_vessel = get_tree().get_nodes_in_group("vessels").pick_random()
	if current_index >= len(get_tree().get_nodes_in_group("vessels")):
		current_index = 0
	followed_vessel.hud_link(false)
	followed_vessel = get_tree().get_nodes_in_group("vessels")[current_index]
	followed_vessel.hud_link(true)
	current_index += 1
	_update_followed_relationships()


func _on_nav_mode_list_item_selected(index):
	followed_vessel.pilot.update_navmode(index)


func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	followed_vessel.pilot.update_navmode(index)


func _on_direct_control_button_toggled(button_pressed):
	$PlayerHudHandler.set_active(button_pressed)
	if button_pressed:
		if followed_vessel:
			followed_vessel.pilot.torque_input.disconnect(followed_vessel.vesselcontroller.update_control_torque)
			followed_vessel.pilot.force_input.disconnect(followed_vessel.vesselcontroller.update_control_force)
			
			$PlayerInputHandler.force_input.connect(followed_vessel.vesselcontroller.update_control_force)
			$PlayerInputHandler.torque_input.connect(followed_vessel.vesselcontroller.update_control_torque)
	else:
		if followed_vessel:
			$PlayerInputHandler.force_input.disconnect(followed_vessel.vesselcontroller.update_control_force)
			$PlayerInputHandler.torque_input.disconnect(followed_vessel.vesselcontroller.update_control_torque)
			followed_vessel.pilot.torque_input.connect(followed_vessel.vesselcontroller.update_control_torque)
			followed_vessel.pilot.force_input.connect(followed_vessel.vesselcontroller.update_control_force)
		


func _on_aggressive_mode_toggled(button_pressed):
	if followed_vessel:
		followed_vessel.vesselcontroller.set_aggressive(button_pressed)


func _on_option_button_item_selected(index):
	var vessel = $VFlowContainer/OptionButton.get_item_metadata(index)
	followed_vessel.pilot.update_navtarget(vessel.rb)


func _on_custom_button_pressed():
	followed_vessel.pilot.spawn_drones()


func _on_line_edit_text_submitted(new_text):
	match new_text:
		"range10": followed_vessel.pilot.set_drone_distance(10)
		"range20": followed_vessel.pilot.set_drone_distance(20)
		"range50": followed_vessel.pilot.set_drone_distance(50)
		"focusme": followed_vessel.pilot.set_drone_focus(followed_vessel.rb.global_position)
		"focustgt": followed_vessel.pilot.set_drone_focus(followed_vessel.pilot.targeting_manager.get_wpos())
		"destroy": followed_vessel.pilot.set_drone_destroy()
		_: pass
