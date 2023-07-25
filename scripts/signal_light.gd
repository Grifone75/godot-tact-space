extends Node3D

var timers = [1.5,.1,.1,.1]
# Called when the node enters the scene tree for the first time.
func _ready():
	#$body/green.light_energy = 0
	#$body/red.light_energy = 1
	$body/white.light_energy = 1
	_light_cycle()



func _light_cycle():
	await get_tree().create_timer(randf_range(0,1)).timeout
	while true:
		#$body/green.light_energy = $body/red.light_energy
		#$body/red.light_energy = 1 - $body/red.light_energy
		$body/white.light_energy = 1 - $body/white.light_energy
		var timer = timers.pop_front()
		timers.push_back(timer)
		await get_tree().create_timer(timer).timeout
