
class_name Pid_f

enum derivative_measurement {velocity, error_rate_of_change}
var proportional_gain
var derivative_gain
var integral_gain

var integration_stored = 0
var error_last = 0
var value_last = 0
var velocity
@export var der_mes:derivative_measurement
@export var integral_saturation:float = 10
@export var output_min: float = -100
@export var output_max: float = 100
var derivative_initialized:bool = false

func _init(p:float,i:float,d:float):
	self.proportional_gain = p
	self.derivative_gain = d
	self.integral_gain = i
	
func reset():
	derivative_initialized = false
	
func update(dt,current_value, target_value):
	var error = target_value - current_value
	
	# calculate proportional term
	var p = proportional_gain * error
	
	# calculate integral term
	integration_stored = clampf(
		integration_stored + (error * dt),
		-integral_saturation,
		integral_saturation
		)
		
	var i = integral_gain * integration_stored
	
	#calculate both derivative terms
	var error_rate_of_change = (error - error_last) / dt
	error_last = error
	
	var value_rate_of_change = (current_value - value_last) / dt
	value_last = current_value
	velocity = value_rate_of_change
	
	var derive_measure = 0
	if derivative_initialized:
		if der_mes == derivative_measurement.velocity:
			derive_measure = -value_rate_of_change
		else:
			derive_measure = error_rate_of_change
	else:
		derivative_initialized = true

	var d = derivative_gain * derive_measure
	
	var result = p + i + d
	
	return clampf(result,output_min, output_max)
	
	
