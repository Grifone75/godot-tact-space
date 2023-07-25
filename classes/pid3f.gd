class_name Pid_3f

var x:Pid_f
var y:Pid_f
var z:Pid_f

func _init(p,i,d):
	self.x = Pid_f.new(p,i,d)
	self.y = Pid_f.new(p,i,d)
	self.z = Pid_f.new(p,i,d)
	
func update(dt,current_value:Vector3, target_value:Vector3):
	
	return Vector3(
		x.update(dt,current_value.x, target_value.x),
		y.update(dt,current_value.y, target_value.y),
		z.update(dt,current_value.z, target_value.z)
	)
	



