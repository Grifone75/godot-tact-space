@tool 
extends Node

@export var construction_data : Space_construction_class

@export var instance_it = false : set = _instance_me

@export var initial_position: Vector3 = Vector3(0,0,0) 

@export var rb:RigidBody3D
@export var pilot:Node
@export var smooth: Node3D
@export var vesselcontroller: Node

@export var faction : Faction = null
@export var vessel_class = ""


var functionals = {
	
}


var all_models

var fixed_choices : Dictionary

var colliders : Dictionary

var col
var col_dark
var col_utility
var col_complement
var blueprint = {}


func _get_components_by_father_and_link(father_node_name,link_name):
	""" retrieve a suitable component name from the given father and link names
	"""
	var regex = RegEx.new()
	var match_subset = {}
	for father_pattern in construction_data.matches.keys():
		regex.compile(father_pattern)
		if regex.search(father_node_name):
			match_subset = construction_data.matches[father_pattern]
			break
	#now get the list of components
	#1st reverse match the link_name to the link base name in the match_subset keys
	#ex. attach_m_side.001 will match attach_m_side
	var result_component_list = []
	for base_name in match_subset.keys():
		regex.compile(base_name)
		if regex.search(link_name):
			result_component_list = match_subset[base_name]
			break
	#print(typeof(result_component_list))
	if typeof(result_component_list) == TYPE_DICTIONARY:
		var variant_fixed = result_component_list.get("novarying") 
		#print("variant fixed ",variant_fixed)
		if variant_fixed != null:
			var variant = fixed_choices.get(variant_fixed)
			if variant == null:
				#let's pick it
				variant = result_component_list.get("list").pick_random()
				#print("setting up variant to ", variant)
				fixed_choices[variant_fixed] = variant
			result_component_list = [variant]
	return result_component_list
	



func _get_children_by_pattern(father_node,pattern):
	""" given a father node and a pattern, retrieve all children matching the pattern
	"""
	var regex = RegEx.new()
	regex.compile(pattern)
	var candidates = []
	for child in father_node.get_children():
		if regex.search(child.name):
			candidates.append(child)
	return candidates
	
func _set_colors_to_tree(node,colors):
	if node.get_class() == "MeshInstance3D":
		node.set_instance_shader_parameter("albedo", col)
		node.set_instance_shader_parameter("tile_albedo", col_dark)
		node.set_instance_shader_parameter("utility_albedo", col_utility)
		node.set_instance_shader_parameter("main_color", col_complement)
	for child in node.get_children():
		_set_colors_to_tree(child,colors)
	
func _pick_model_from_blender_library(name):
	
	var functional_class = construction_data.functional_mapping.get(name)
	var selected_mi
	var collisionshape = null
	
	if name.begins_with("res://"):
		selected_mi = load(name).instantiate()

	else:
		var matching_nodes = _get_children_by_pattern(all_models,name) #.pick_random().duplicate()
		# here check if the result contains olso StaticBody3D nodes or only MeshInstance3D	func filtermesh(n):
		var mi3Ds = matching_nodes.filter(func(x): return x.get_class() == "MeshInstance3D" )
		#pick an item and check if node contains q shqpe3d
		selected_mi = mi3Ds.pick_random().duplicate()  
		
		if selected_mi.has_node("StaticBody3D"):
			#extract shape and delete staticbody node
			var sb = selected_mi.get_node("StaticBody3D")
			collisionshape = selected_mi.get_node("StaticBody3D/CollisionShape3D")

			sb.remove_child(collisionshape)
			selected_mi.remove_child(sb)

	if functional_class:
		if functionals.get(functional_class):
			functionals[functional_class].append(selected_mi)
		else:
			functionals[functional_class] = [selected_mi]
	#test color override here
	var colors = {
				"albedo": col,
				"tile_albedo": col_dark,
				"utility_albedo": col_utility,
				"main_color": col_complement,
			}
	if selected_mi.has_method("set_material_properties"):
		selected_mi.set_material_properties(colors)
	else: _set_colors_to_tree(selected_mi,colors)
	
	return {"mi3D":selected_mi,"cs3D":collisionshape}
	
	
	
func _expand_connectors(current_node) -> Array:
	""" given current node, cycle all links of type attach_m and expand them
	""" 
	#print("expanding ",current_node.name)
	var partial_blueprint = {}
	var partial_blueprint_components = {}
	var links_to_expand = _get_children_by_pattern(current_node, "attach_m")
	#print("..found links :",links_to_expand)
	var component_name
	var component_names
	for link in links_to_expand:
		#retrieve a suitable component
		#print("...checking link ",link.name)
		component_names = _get_components_by_father_and_link(current_node.name,link.name)
		#print("....found components",component_names)
		if len(component_names)>0:
			component_name = component_names.pick_random()
			#print(component_name)
			var component_cloned = _pick_model_from_blender_library(component_name)
			add_child(component_cloned.mi3D)
			#TODO wip add colliders
			if component_cloned.cs3D: colliders[component_cloned.mi3D.get_instance_id()] = component_cloned.cs3D
			var expansion_result = _expand_connectors(component_cloned.mi3D)
			component_cloned.mi3D = expansion_result[0]
			partial_blueprint_components[link.name] = expansion_result[1]
			_attach_component_to_father(current_node,link,component_cloned.mi3D)
		else:
			pass
	partial_blueprint[current_node.name] = partial_blueprint_components
	return [current_node, partial_blueprint]
	

func _attach_component_to_father(father,father_link,component):
	var component_link_f = _get_children_by_pattern(component,"attach_f")[0]
	#print("......attaching component ",component.name, " to parent ", father)
	var master_attach = get_node(father_link.get_path())
	var component_attach = get_node(component_link_f.get_path())
	
	component.get_parent().remove_child(component)
	father.add_child(component, true)

	# we need to :
	# get the transformation from moving_t to target_t and apply it to c
	var qcomp = Quaternion(component_attach.global_transform.basis)
	var qmast = Quaternion(master_attach.global_transform.basis)
	var delta_rot = qmast * Quaternion(qcomp).inverse() 
	component.global_transform.basis = Basis(delta_rot * Quaternion(component.global_transform.basis))
	component.global_transform.origin += (master_attach.global_transform.origin - component_attach.global_transform.origin)
	# exp remove links
	component_attach.queue_free()
	master_attach.queue_free()
	

func _instance_me(_p = null):
	all_models = load(construction_data.model_scene_path).instantiate()

	var body = _pick_model_from_blender_library(construction_data.root_pattern)
	
	var my_rb = self.get_node("VesselController/RigidBody3D")
	var my_mesh_attach = self.get_node("VesselController/RigidBody3D/Smoothing")
	
	body.mi3D.transform.origin = Vector3.ZERO
	#body.mi3D.look_at(my_rb.global_transform.origin + my_rb.to_global(Vector3.LEFT))
	body.mi3D.transform = body.mi3D.transform.rotated(Vector3(1,0,0),PI/2.)
	
	my_mesh_attach.add_child(body.mi3D)
	if body.cs3D: colliders[body.mi3D.get_instance_id()] = body.cs3D
	var expansion_results = _expand_connectors(body.mi3D) 
	body.mi3D = expansion_results[0]
	blueprint = expansion_results[1]
	for mesh_instance_id in colliders.keys():
		var mi = instance_from_id(mesh_instance_id)
		var collider = colliders[mesh_instance_id]
		collider.global_transform = mi.global_transform

		#
		my_rb.add_child(collider)
	#b.transform.origin = Vector3(randf_range(-20,20),randf_range(-20,20),randf_range(-20,20))
	all_models = null
	print("all is ok")
	

func _christen():
	return construction_data.get_construction_name()

func _materialize():
	vesselcontroller = load("res://scenes/VesselController.tscn").instantiate()
	self.add_child(vesselcontroller)
	vesselcontroller.functionals = functionals
	rb = self.get_node("VesselController/RigidBody3D")
	smooth = self.get_node("VesselController/RigidBody3D/Smoothing")
	vessel_class = construction_data.vessel_class
	
	_instance_me()
	
	rb.global_transform.origin = initial_position
	
	pilot = load("res://scenes/AIPilot.tscn").instantiate()
	pilot.name = "AIPilot"
	self.add_child(pilot)
	self.name = _christen()
	#test alignment
	self.get_node("VesselController/RigidBody3D").look_at(
		Vector3(
			randf_range(-1,1),
			randf_range(-1,1),
			randf_range(-1,1)
			))
			
	var label = load("res://scenes/info_label_1.tscn").instantiate()
	smooth.add_child(label)
	pilot.pilot_info.connect(smooth.get_node("VesselInfo").update_pilot_label)
	#connecting signals
	pilot.torque_input.connect(vesselcontroller.update_control_torque)
	pilot.force_input.connect(vesselcontroller.update_control_force)
	pilot.changed_target.connect(vesselcontroller.update_nav_target)
	vesselcontroller.vessel_info.connect(smooth.get_node("VesselInfo").update_vessel_label)
	smooth.get_node("VesselInfo").set_shipname(self.name, self.faction.name)
	var tracer = load("res://scenes/path_trace_hud.tscn").instantiate()
	smooth.add_child(tracer)
	tracer.traced_vessel = smooth

	add_child(load("res://origin_shiftable.tscn").instantiate())

	add_child(load("res://contactable.tscn").instantiate().set_linked_rb(rb).set_type(vessel_class))

	var missionplayer = load("res://scenes/missionplayer.tscn").instantiate()
	missionplayer.ref_pilot = pilot
	missionplayer.load_mission(construction_data.initial_mission_path.instantiate())
	add_child(missionplayer)
	
	if len(functionals.get("dockports",[]))>0:
		add_child(load("res://scenes/traffic_manager.tscn").instantiate())
	
	for banner in functionals.get("banners",[]):
		banner.update_text(self.name)

	



# Called when the node enters the scene tree for the first time.
func _ready():
	pass

	
func materialize(_faction:Faction = null):
	randomize()
	if _faction :
		faction = _faction
	elif faction == null:
		faction = Faction.new()
	else:
		pass

	col = faction.main_color
	col_dark = faction.color_dark
	col_complement = faction.color_complement
	col_utility = faction.color_utility
	_materialize()
	
func dematerialize():
	# temporary implementation
	# somewhere here we should also put the serialization 
	if rb:
		rb.queue_free()
		rb = null
	if pilot:
		pilot.queue_free()
		pilot = null
	if vesselcontroller:
		vesselcontroller.queue_free()
		vesselcontroller = null
	if smooth:
		smooth.queue_free()
		smooth = null
			

	
func hud_link(is_active:bool):
	if is_active:
		#thruster update
		#TODO this should be handled the other way around : 
		# the MFD is rsponsible for its elements. We should only populate it and clear it by sending it a list of
		#the thrusters
		for thruster in functionals.get("thrusters",[]):
			var el = load("res://scenes/ui/ui_hud_element.tscn").instantiate()
			$/root/base/PlayerUI/MFD/SYS/UNK.add_child(el)
			thruster.current_thrust.connect(el.update_values)
			
		var nav_panel = load("res://scenes/ui/ui_hud_nav.tscn").instantiate()
		$/root/base/PlayerUI/MFD/NAV.add_child(nav_panel)
		self.pilot.pilot_info.connect(nav_panel.update_values)
		
	if !is_active:
		for el in $/root/base/PlayerUI/MFD/SYS/UNK.get_children():
			el.queue_free()
		for el in $/root/base/PlayerUI/MFD/NAV.get_children():
			el.queue_free()
	

func get_rb():
	return rb
	
func request_docking():
	return {"dockport1":null}


func manage_origin_shift(shift_value):
	rb.global_position -= shift_value
	smooth.teleport()
