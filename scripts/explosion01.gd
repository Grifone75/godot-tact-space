extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$exp.emitting = true
	await get_tree().create_timer(2.).timeout
	call_deferred("free")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
