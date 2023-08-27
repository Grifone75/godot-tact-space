extends Control

enum BEHAVIOURS {MAIN,VELOCITY}
@export var behaviour : BEHAVIOURS
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if behaviour == BEHAVIOURS.MAIN:
		var distance = 999999.0
		if $/root/base.followed_vessel != null:
			var focus_node = $/root/base.followed_vessel.get_node("VesselController/RigidBody3D")
			var targeting = $/root/base.followed_vessel.get_node("AIPilot").targeting_manager
			if targeting.current_target != null:
						
				distance = (focus_node.global_position - targeting.get_wpos()).length()
				$Distance.text = "d: {} m".format(["%0.2f" % (distance*10.0)],"{}")
				if distance > 6000:
					self.hide()
				else:
					self.show()
					if (focus_node.get_viewport().get_camera_3d().is_position_behind(targeting.get_wpos())):
						self.hide()
					else:
						self.show()
						var screen_pos = focus_node.get_viewport().get_camera_3d().unproject_position(targeting.get_wpos())
						self.set_global_position(screen_pos)
	if behaviour == BEHAVIOURS.VELOCITY:
		if $/root/base.followed_vessel != null:
			var focus_node = $/root/base.followed_vessel.get_node("VesselController/RigidBody3D")
			var targeting = $/root/base.followed_vessel.get_node("AIPilot").targeting_manager
			var wprojpos
			if targeting.current_target != null:
				var velocity = focus_node.linear_velocity - targeting.get_wvel()
				wprojpos = focus_node.global_position + velocity*100.0
				$Velocity.text = "v: {} m/s".format(["%0.2f" % (velocity.length()*10.0)],"{}")
				var screen_pos = focus_node.get_viewport().get_camera_3d().unproject_position(wprojpos)
				if (focus_node.get_viewport().get_camera_3d().is_position_behind(wprojpos)):
					$full_circle.hide()
					$x.show()
					self.set_global_position(screen_pos)
				else:
					$full_circle.show()
					$x.hide()
					self.set_global_position(screen_pos)
					
