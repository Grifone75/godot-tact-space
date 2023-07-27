@tool 
extends Node



@export var instance_it = false : set = _instance_me

@export var initial_position: Vector3 = Vector3(0,0,0) 

@export var matches = {
	"center_[0-9]":{
		"attach_m_side":["side_2","side_1","side_5", "side_6", "side_4", "side_7"],
		"attach_m_front":["front4_h", "front5_h", "front2_h", "front1"],
		"attach_m.back":["^engine1","enginehub","enginehub2","enginehub3"],
		"attach_mback":["^engine1","enginehub","enginehub2","enginehub3"],
		"attach_m_module_small":["ship_module_scanner","ship_module_omnisensor"],
		"attach_m_weapon":["res://scenes/gun_1.tscn"]
	},
	"side_[0-9]":{
		"attach_m_weapon":["res://scenes/gun_1.tscn"]	
	},
	"front[0-9](_h)*":{
		"attach_m_side":["fr_section2_h","fr_section3_h", "fr_section4_h"],
		"attach_m_module_small":["ship_module_scanner"],
		"attach_m_rcs":["res://scenes/thruster_small.tscn"]	,
		"attach_m_signal_light":["res://scenes/signal_light.tscn"]	
	},
	"fr_section":{
		"attach_m_module_small":["ship_module_omnisensor"],
		"attach_m_rcs":["res://scenes/thruster_small.tscn"]	
	},
	"enginehub[0-9]*":{
		"attach_m_sideengine":{"novarying":"engine", "list":["side_engine1","side_engine2","side_engine3"]},
		"attach_m_rcs":["res://scenes/thruster_small.tscn"]	
	},
	"^engine[0-1]*":{
		"attach_m_thruster":["res://scenes/thruster.tscn"],
	},
	"side_engine[0-9]*":{
		"attach_m_thruster":["res://scenes/thruster.tscn"],
		"attach_m_rcs":["res://scenes/thruster_small.tscn"]	
	}
	
}

var functional_mapping = {
	"res://scenes/thruster.tscn":"thrusters",
	"res://scenes/thruster_small.tscn":"thrusters",
	"res://scenes/gun_1.tscn":"turrets"
}

var functionals = {
	
}


var all_models

var fixed_choices : Dictionary

var colliders : Dictionary

var col
var col_dark
var col_utility
var col_complement

var names = [
	{
		"n1":["The Phoenix","The Cascade","The Thunderstorm","The Curator","The Face Of Death","The Stalker","The Brimstone","The Black Talon","The Leech","The Necro","The Homage","The Giant's Fist","The Eventide","The Mongrel","The Curtain's Fall","The Specter","The Storm Cloud","The Requiem","The Bloodlord","The Flame Wall"]
	},
	{
		"n0":["Pride of the ","Nation of the ", "Force of the ", "Gift of the ", "Sword of the ", "Hand of the "],
		"n1":["Etralese","Ashiaonian","Tredalic","Clasteiniot","Yogrurino","Woclurese","Hoslioanian","Jaseno","Stroain","Trieri","Uchurgish","Eglaanian","Scuguaiote","Sheyguaiote","Zecresese","Leblean","Quscii","Lutriene","Skiaite","Scaihasonian","Uwhosene","Aclonite","Shiusauanian","Smoelori","Coshoese","Bawhijaian","Tusnino","Qatrier","Striehonian","Pluypiote"]
	},
	{
		"n0":["Home of ", "", "Eye of "],
		"n1":["The Serpent Raiders","The Berserker Bandits","The Rusty Bandits","The Merpeople Raiders","The Pirates of the North","The Pillagers of the Great Lake","The Bandits of the Plank","The Salty Dogs","The Blackbeards","The Crazy Eyes","The Nightmare Corsairs","The Neptune Raiders","The White Shark Plunderers","The Berserker Pirates","The Bandits of the North","The Pirates of the Black Squid","The Bandits of the Sanguine Flag","The Hired Guns","The Skull and Crossbones","The Shellbacks","The Merpeople Buccaneers","The Mermaid Buccaneers","The Seashell Pirates","The East Sea Rovers","The Buccaneers of the Inner Sea","The Pirates of the Lost Treasure","The Rovers of the Bloodied Flag","The Barnacles","The Black Skulls","The Black Tooth Grins"]
	},
	{
		"n1":["The Aether Soul", "The Devil Blood", "The Blood Blood", "The Evenheart", "The Chaos One", "The Stellar Heart", "The Wondergift", "The Spell Child", "The Virtuechild", "The Fatesoul", "The Frostchild", "The Divine Child", "The Demon Blood", "The Wrath Gift", "The Pure Soul", "The Blood Soul", "The Furor Gift", "The Dead Blood", "The Radiant One", "The Faye Soul "]
	},
	{
		"n1":["Ambystoma","Scorpaenidae","Squalus","Alcelaphinae Major","Scorpaenidae Major","Violet Sheep","Black Trout","Eastern Scarf","Western Horn","Western Robe","Papilionoidea","Sarcophilus","Simia","Oniscidea Borealis","Anguis Occidentalis","Amethyst Rat","Vermilion Trout","Eastern Arrow","Large Telescope","Small Ship","Achatina","Dermaptera","Ramphastos","Dromaius Occidentalis","Enhydra Major","Harlequin Porcupine","Red Goose","Big Brush","Small Airplane","Large Couldron","Cichlidae","Chelonioidea","Rhinoceros","Caeli Orientalis","Dynastes Australis","Emerald Starfish","Violet Kangaroo","Northern Fountain","Eastern Spade","Big Wrench"]
	}
]




func _get_components_by_father_and_link(father_node_name,link_name):
	""" retrieve a suitable component name from the given father and link names
	"""
	var regex = RegEx.new()
	var match_subset = {}
	for father_pattern in matches.keys():
		regex.compile(father_pattern)
		if regex.search(father_node_name):
			match_subset = matches[father_pattern]
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
	print(typeof(result_component_list))
	if typeof(result_component_list) == TYPE_DICTIONARY:
		var variant_fixed = result_component_list.get("novarying") 
		print("variant fixed ",variant_fixed)
		if variant_fixed != null:
			var variant = fixed_choices.get(variant_fixed)
			if variant == null:
				#let's pick it
				variant = result_component_list.get("list").pick_random()
				print("setting up variant to ", variant)
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
	
func _pick_model_from_blender_library(name):
	
	var functional_class = functional_mapping.get(name)
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
	if selected_mi.get_class() == "MeshInstance3D":
		selected_mi.set_instance_shader_parameter("albedo", col)
		selected_mi.set_instance_shader_parameter("tile_albedo", col_dark)
		selected_mi.set_instance_shader_parameter("utility_albedo", col_utility)
		selected_mi.set_instance_shader_parameter("main_color", col_complement)
	return {"mi3D":selected_mi,"cs3D":collisionshape}
	
	
	
func _expand_connectors(current_node) -> Node:
	""" given current node, cycle all links of type attach_m and expand them
	""" 
	#print("expanding ",current_node.name)
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
			component_cloned.mi3D = _expand_connectors(component_cloned.mi3D)
			_attach_component_to_father(current_node,link,component_cloned.mi3D)
			
		else:
			pass
	return current_node
	

func _attach_component_to_father(father,father_link,component):
	var component_link_f = _get_children_by_pattern(component,"attach_f")[0]
	#print("......attaching component ",component.name, " to parent ", father)
	var master_attach = get_node(father_link.get_path())
	var component_attach = get_node(component_link_f.get_path())
	
	component.get_parent().remove_child(component)
	father.add_child(component)

	# we need to :
	# get the transformation from moving_t to target_t and apply it to c
	var qcomp = Quaternion(component_attach.global_transform.basis)
	var qmast = Quaternion(master_attach.global_transform.basis)
	
	var delta_rot = qmast * Quaternion(qcomp).inverse() 
	
	component.global_transform.basis = Basis(delta_rot * Quaternion(component.global_transform.basis))
	
	
	component.global_transform.origin += (master_attach.global_transform.origin - component_attach.global_transform.origin)
	

func _instance_me(_p = null):
	all_models = load("res://data/models/all_ships_and_stations.blend").instantiate()

	var body = _pick_model_from_blender_library("center_[0-9]")

	
	#transform = body.mi3D.transform.rotated(Vector3(1,0,0),PI/2.)
	
	var my_rb = self.get_node("VesselController/RigidBody3D")
	var my_mesh_attach = self.get_node("VesselController/RigidBody3D/Smoothing")
	
	body.mi3D.transform.origin = Vector3.ZERO
	#body.mi3D.look_at(my_rb.global_transform.origin + my_rb.to_global(Vector3.LEFT))
	body.mi3D.transform = body.mi3D.transform.rotated(Vector3(1,0,0),PI/2.)
	
	my_mesh_attach.add_child(body.mi3D)
	if body.cs3D: colliders[body.mi3D.get_instance_id()] = body.cs3D
	body.mi3D = _expand_connectors(body.mi3D)
	for mesh_instance_id in colliders.keys():
		var mi = instance_from_id(mesh_instance_id)
		var collider = colliders[mesh_instance_id]
		collider.global_transform = mi.global_transform

		#
		my_rb.add_child(collider)
	#b.transform.origin = Vector3(randf_range(-20,20),randf_range(-20,20),randf_range(-20,20))
	
	print("all is ok")
	

func _christen():
	var ship_name = ""
	for group in names.pick_random().values():
		ship_name += group.pick_random()
	return ship_name

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	col = [
		Color.from_ok_hsl(randf_range(0.,1.),randf_range(0.1,.5),randf_range(.6,.9)),
		Color.from_ok_hsl(randf_range(0.,1.),randf_range(0.7,1.),randf_range(.1,.4))
		].pick_random()
	col_dark = col.darkened(.7)
	col_complement = [
		Color.from_hsv(fmod(col.h+randf_range(-0.1,0.1),1.),col.s*1.5,.2),
		Color.from_hsv(fmod(col.h+.5,1.),col.s,.3),
		Color.from_hsv(fmod(col.h+randf_range(-0.1,0.1),1.),col.s*0.5,.8)
		].pick_random()
	var utilities = [Color("f0b31a"),Color("ff8c1a"),Color("ffe400"),Color("e7c2d2"),Color("101010"), col_complement]
	#col_utility = utilities[0]
	#var opp_hue = col.h + 0.5
	#if opp_hue > 1: opp_hue -= 1.
	#col_utility = Color.from_ok_hsl(opp_hue,.9,.5)
	col_utility = utilities.pick_random()
	#for ucol in utilities:
	#	if abs(ucol.h - opp_hue) < abs(col_utility.h - opp_hue):
	#		col_utility = ucol
	
	
	var vcontroller = load("res://scenes/VesselController.tscn").instantiate()
	self.add_child(vcontroller)
	vcontroller.functionals = functionals
	var rb = self.get_node("VesselController/RigidBody3D")


	_instance_me()
	rb.global_transform.origin = initial_position
	
	var pilot = load("res://scenes/AIPilot.tscn").instantiate()
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
	rb.add_child(label)
	$AIPilot.pilot_info.connect($VesselController/RigidBody3D/VesselInfo.update_pilot_label)
	#connecting signals
	$AIPilot.torque_input.connect($VesselController.update_control_torque)
	$AIPilot.force_input.connect($VesselController.update_control_force)
	$AIPilot.changed_target.connect($VesselController.update_nav_target)
	$VesselController.vessel_info.connect($VesselController/RigidBody3D/VesselInfo.update_vessel_label)
	$VesselController/RigidBody3D/VesselInfo/ShipName.text = self.name
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_rb():
	return $VesselController/RigidBody3D
