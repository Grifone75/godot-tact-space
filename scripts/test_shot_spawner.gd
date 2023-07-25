extends Node3D

var time_start:float
var next_clock:float

# Called when the node enters the scene tree for the first time.
func _ready():
	time_start = Time.get_unix_time_from_system()
	next_clock = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var elapsed = Time.get_unix_time_from_system() - time_start
	if elapsed > next_clock:
		var shot = load("res://scenes/base_shot.tscn").instantiate()
		get_tree().get_root().add_child(shot)
		shot.global_position = self.global_position
		shot.global_transform.basis = self.global_transform.basis

		
		
		next_clock += 1
