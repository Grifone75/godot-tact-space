extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

	
func update_vessel_label(vesselvalue):
		$VesselControllerInfo.text = str(vesselvalue)

func update_pilot_label(aivalue):
		$AIPilotInfo.text = str(aivalue)
