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
	

func tune_derivative_gain(factor):
	x.derivative_gain = factor
	y.derivative_gain = factor
	z.derivative_gain = factor


func tune_proportional_gain(factor):
	x.proportional_gain = factor
	y.proportional_gain = factor
	z.proportional_gain = factor

