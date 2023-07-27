extends Node

signal force_input
signal torque_input


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	var MAX_TORQUE = 10.0
	var MAX_FORCE = 10.0
	
	# for the time being, let's use a modifier button (A) to switch between axial translation and torque
	var ax = Input.is_joy_button_pressed(0, 0)
	
	var tx_raw = Input.get_joy_axis(0,JOY_AXIS_LEFT_X)
	var ty_raw = Input.get_joy_axis(0,JOY_AXIS_LEFT_Y)
	var ax_x = 0
	var ax_y = 0
	
	if not ax:
		var tx = signf(tx_raw) * ease(absf(tx_raw),3) * MAX_TORQUE
		var ty = signf(ty_raw) * ease(absf(ty_raw),3) * MAX_TORQUE
		torque_input.emit(Vector3(-ty,-tx,0.0))

	else:
		ax_x = signf(tx_raw) * ease(absf(tx_raw),3) * MAX_FORCE
		ax_y = signf(ty_raw) * ease(absf(ty_raw),3) * MAX_FORCE
		
	var fplus_raw = Input.get_joy_axis(0,JOY_AXIS_TRIGGER_LEFT)
	var fminus_raw = Input.get_joy_axis(0,JOY_AXIS_TRIGGER_RIGHT)
	
	var fplus = signf(fplus_raw) * ease(absf(fplus_raw),3) * MAX_FORCE
	var fminus = signf(fminus_raw) * ease(absf(fminus_raw),3) * MAX_FORCE
	
	force_input.emit(Vector3(-ax_x,-ax_y,fplus-fminus))
	
func _input(event):
	if event is InputEventJoypadMotion:
		print(
				"Device: %s. Joypad Axis Index: %s. Strength: %s."
				% [event.device, event.axis, event.axis_value]
		)
		var base_torque = Vector3.ZERO
		var base_force = Vector3.ZERO
		
		if (event.axis == 4):
			base_force = Vector3(0,0,event.axis_value)
		if (event.axis == 5):
			base_force = Vector3(0,0,-event.axis_value)
		if (event.axis == 0):
			base_torque = Vector3(event.axis_value*10,0,0)
		if (event.axis == 1):
			base_torque = Vector3(0,event.axis_value*10,0)
		
		#force_input.emit(base_force)
		#torque_input.emit(base_torque)
