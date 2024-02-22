extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$to_save/m1.owner = $to_save
	$to_save/m2.owner = $to_save
	$to_save/m3.owner = $to_save


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			var scene = PackedScene.new()
			scene.pack($to_save)
			ResourceSaver.save(scene,"scene_save_test.tscn")
			print("T was pressed")
			print($to_save/m1.owner)
