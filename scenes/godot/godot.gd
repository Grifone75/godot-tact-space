extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	scene_changer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func scene_changer():
	
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_file("res://base.tscn")

	
	
