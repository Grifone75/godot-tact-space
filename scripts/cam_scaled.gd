extends Camera3D

@export var master:Camera3D
@export var factor:float

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _update():
	if factor > 0:
		self.global_transform.origin = master.global_transform.origin / factor
	self.global_transform.basis = master.global_transform.basis
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta):
#	_update()

func _process(delta):#process(delta):
	_update()
