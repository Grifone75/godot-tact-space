@tool
extends Node3D

@export var instance_it : bool = false : set = _instance_me

@export var patterns = ["side_[0-9]","front[0-9](_h)*","fr_section","enginehub[0-9]*","^engine[0-1]*","side_engine[0-9]*"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _match_patterns(_name,patterns):
	""" given a name and a list of patterns, return true if name matches any the patterns
	"""
	var regex = RegEx.new()
	print(patterns)
	for pattern in patterns:
		regex.compile(pattern)
		if regex.search(_name):
			return true
	return false


func _instance_me(yes: bool):
	var all_models = load("res://data/models/all_ships_and_stations.blend").instantiate()
	var pos = Vector3.ZERO
	var count = 0
	var row = 0
	for el in all_models.get_children():
		if _match_patterns(el.name,patterns):
			print("now processing ",el.name)
			el.get_parent().remove_child(el)
			self.add_child(el)
			el.set_owner(get_tree().get_edited_scene_root())
			el.global_position = pos
			pos += Vector3.FORWARD*3
			count+=1
			if count > 10:
				count = 0
				row += 1
				pos = Vector3.RIGHT * row * 5 
	
