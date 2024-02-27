extends Node3D

var cam_tracked = null #TODO not used?
var followed_vessel
var moving_origin: bool = false
var mouse_focused_object = null
@export var cam: Node3D = null
# Called when the node enters the scene tree for the first time.
func _ready():
	#DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	$SubViewportContainer/SubViewport_objects.connect("size_changed", _on_viewport_resize)
	$SubViewport_planets.connect("size_changed", _on_viewport_resize)
	cam.tracked_updated.connect(func(x) : cam_tracked = x)
	_delayed_init()
	_wide_event_checker()
	_star_system_loader()

func _on_viewport_resize():
	print_debug("*** SIZE CHANGED")
	print_debug($SubViewportContainer/SubViewport_objects.size)
	#$SubViewport_UI.size = $SubViewportContainer/SubViewport_objects.size
	$SubViewport_planets.size = $SubViewportContainer/SubViewport_objects.size
	

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
	#print("*** calling OShift, delta: ",shift)
	for obj in get_tree().get_nodes_in_group("origin_shiftables"):
		obj.do_origin_shift(shift)
	#cam.reset_origin() #not necessary anymore as the camera is on a object which is already shifted
	moving_origin = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var _time = Time.get_ticks_msec() / 1000.0
	var origin_shift_treshold
	if is_warping:
		origin_shift_treshold = 20000
	else:
		origin_shift_treshold = 2000

	if (cam.global_position.length() > origin_shift_treshold) and !moving_origin:
		_origin_shift()

	# DebugDraw.set_text("Time", _time)
	# DebugDraw.set_text("Frames drawn", Engine.get_frames_drawn())
	# DebugDraw.set_text("FPS", Engine.get_frames_per_second())
	# DebugDraw.set_text("delta", delta)



func _on_button_pressed():
	var nav = get_tree().get_nodes_in_group("contactables").pick_random()
	followed_vessel_change_nav_target(nav)



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
	if button_pressed:
		if followed_vessel:
			followed_vessel.pilot.torque_input.disconnect(followed_vessel.vesselcontroller.update_control_torque)
			followed_vessel.pilot.force_input.disconnect(followed_vessel.vesselcontroller.update_control_force)
			
			followed_vessel.pilot.torque_input.connect($PlayerInputHandler.base_ai_torque_input)
			followed_vessel.pilot.force_input.connect($PlayerInputHandler.base_ai_force_input)
			
			$PlayerInputHandler.force_input.connect(followed_vessel.vesselcontroller.update_control_force)
			$PlayerInputHandler.torque_input.connect(followed_vessel.vesselcontroller.update_control_torque)
	else:
		if followed_vessel:
			$PlayerInputHandler.force_input.disconnect(followed_vessel.vesselcontroller.update_control_force)
			$PlayerInputHandler.torque_input.disconnect(followed_vessel.vesselcontroller.update_control_torque)
			
			followed_vessel.pilot.torque_input.disconnect($PlayerInputHandler.base_ai_torque_input)
			followed_vessel.pilot.force_input.disconnect($PlayerInputHandler.base_ai_force_input)
			$PlayerInputHandler.reset_base_ai_inputs()
			
			followed_vessel.pilot.torque_input.connect(followed_vessel.vesselcontroller.update_control_torque)
			followed_vessel.pilot.force_input.connect(followed_vessel.vesselcontroller.update_control_force)
		


func _on_aggressive_mode_toggled(button_pressed):
	if followed_vessel:
		followed_vessel.vesselcontroller.set_aggressive(button_pressed)


func _on_option_button_item_selected(index):
	var selected_target = $VFlowContainer/OptionButton.get_item_metadata(index)
	followed_vessel_change_nav_target(selected_target)


func followed_vessel_change_nav_target(_contact):
	followed_vessel.pilot.update_navtarget(_contact)


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

var is_warping = false
func _on_warp_test_toggled(button_pressed):
	if followed_vessel:
		is_warping = not is_warping
		followed_vessel.pilot.set_warp(button_pressed)






func _on_camera_base_clicked_object(node):
	mouse_focused_object = node
	$VFlowContainer/Cliked_object.text = node.name if node else ""
	print("clicked on ",node)


func _wide_event_checker():
	# this temporarily here, but it might be moved to a better place later
	#this periodically check if the player is near, nearing or out of a wide area node
	var wa_list
	while true:
		wa_list = get_tree().get_nodes_in_group("wide_area_nodes")
		if followed_vessel and followed_vessel.rb:
			for wan in wa_list:
				if ((followed_vessel.rb.global_position - wan.approx_position).length_squared() < (wan.radius_activation * wan.radius_activation)) :
					wan.on_player_inside()
				elif ((followed_vessel.rb.global_position - wan.approx_position).length_squared() > (wan.radius_deactivation * wan.radius_activation)) :
					wan.on_player_outside()
		await get_tree().create_timer(1.).timeout
	
func _instance_system_object(record, player_pos_asr_mkm):
	if not record['ref']:
		#coords are in absolute system reference and expressed in M of Km
		var far_pos:Vector3 = Vector3(
			record['coords'][0]*10000,#factor is 1M (base uom) * 1k (km to m) /10 (sim factor) / 10000 (far factor)
			record['coords'][1]*10000,
			record['coords'][2]*10000) - Vector3(player_pos_asr_mkm)*10000
		var object = load(record['template']).instantiate()
		
		#var wide_area = load("res://scenes/wide_area_node.tscn").instantiate()
		#wide_area.global_position = far_pos
		object.global_position = far_pos
		object.name = record['name']
		#wide_area.name = object.name + ' area'
		if record['template'] == 'res://scenes/wide_area_node.tscn':
			object.add_child(load("res://contactable.tscn").instantiate().set_space_scale(10000.0))
		if record['template'] == 'res://scenes/gas_giant.tscn':
			object.scale = Vector3(128,128,128)
		$/root/base/SubViewport_planets.add_child(object)
		#$/root/base/SubViewport_planets.add_child(wide_area)
		
	
func _star_system_loader():
	var player_pos_asr_mkm = Vector3(.5,.5,.5)
	var system = [
		{'name':'planet1','template':'res://scenes/gas_giant.tscn','coords':[2,0,0],'ref':null},
		{'name':'planet2','template':'res://scenes/gas_giant.tscn','coords':[1,0,0],'ref':null},
		{'name':'planet3','template':'res://scenes/gas_giant.tscn','coords':[2,2,0],'ref':null},
		{'name':'zone1','template':'res://scenes/wide_area_node.tscn','coords':[3,2,-1],'ref':null},
	]
	for el in system:
		_instance_system_object(el,player_pos_asr_mkm)
	
	pass
