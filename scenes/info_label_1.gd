extends Node3D

@export var shipname = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distance = 999999.0
	if $/root/base.followed_vessel != null:
		distance = ($/root/base.followed_vessel.get_node("VesselController/RigidBody3D").global_position - self.global_position).length()
		$Anchor2D/Distance.text = "d: {} m".format(["%0.2f" % (distance*10.0)],"{}")
	if distance > 300:
		$Anchor2D.hide()
	else:
		$Anchor2D.show()
		if (get_viewport().get_camera_3d().is_position_behind(global_position)):
			$Anchor2D.hide()
		else:
			$Anchor2D.show()
			var screen_pos = get_viewport().get_camera_3d().unproject_position(global_position)
			$Anchor2D.set_global_position(screen_pos)
	
func update_vessel_label(vesselvalue):
		$Anchor2D/VesselControllerInfo.text = str(vesselvalue)

func update_pilot_label(aivalue):
		$Anchor2D/AIPilotInfo.text = str(aivalue)

func set_shipname(sname):
	shipname = sname
	$Anchor2D/Shipname.text = shipname
