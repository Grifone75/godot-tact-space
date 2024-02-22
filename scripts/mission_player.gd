extends Node


# this is the new way 
var _mission

var ref_pilot = null

# Called when the node enters the scene tree for the first time.
func _ready():

	await get_tree().create_timer(2.0).timeout
	#load_mission(load("res://scenes/missions/TestMission.tscn").instantiate())

	await _mission.play()
	if _mission.has_method("outro"):
		_mission.outro()
	


func load_mission(_miss:Node):
	_miss.mplayer = self
	_miss.pilot = ref_pilot
	_miss.vessel = null
	_miss.nav_metrics = ref_pilot.nav_metrics
	_miss.targeting_mgr = ref_pilot.targeting_manager
	add_child(_miss)
	_mission = _miss


func safe_await(t):
	var _timer = Timer.new()
	add_child(_timer)
	_timer.wait_time = t
	_timer.one_shot = true
	_timer.start()
	await _timer.timeout
	_timer.queue_free()
	return


func critical_timer(t):
	print("calling critical timer")
	pass
