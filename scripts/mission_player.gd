extends Node


@export var mission_script: Script = null
var mission = null

var ref_pilot = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_mission_sequencer()

func _mission_sequencer():
	await get_tree().create_timer(2.).timeout
	
	if mission_script and (mission == null):
		print("*** creating new mission")
		mission = mission_script.new(ref_pilot)
	await get_tree().create_timer(2.).timeout
	if mission and (mission.is_playing==false):
		print("*** playing mission")
		mission.play()
