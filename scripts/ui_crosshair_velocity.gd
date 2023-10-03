extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $/root/base.followed_vessel != null:
		var focus_node = $/root/base.followed_vessel.get_node("VesselController/RigidBody3D")
		var targeting = $/root/base.followed_vessel.get_node("AIPilot").targeting_manager
		var wprojpos
		if targeting.current_target != null:
			var velocity = focus_node.linear_velocity - targeting.get_wvel()
			wprojpos = focus_node.global_position + velocity*100.0
			$Velocity.text = Metric.vel2str(velocity.length())
			var screen_pos = focus_node.get_viewport().get_camera_3d().unproject_position(wprojpos)
			if (focus_node.get_viewport().get_camera_3d().is_position_behind(wprojpos)):
				$full_circle.hide()
				$x.show()
				self.set_global_position(screen_pos)
			else:
				$full_circle.show()
				$x.hide()
				self.set_global_position(screen_pos)
