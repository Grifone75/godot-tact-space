class_name Nav_metrics extends Resource

var l_translation_to_target: Vector3 = Vector3.ZERO
var l_velocity_to_target: Vector3 = Vector3.ZERO
var l_vtt_sag: Vector3 = Vector3.ZERO
var l_vtt_sag_pos_len: float = 0.0 
var l_vtt_tan: Vector3 = Vector3.ZERO

var base_rigidbody = null
var target_rigidbody: RigidBody3D = null
var target_object: Node3D = null

var targeting_manager: Targeting_manager

func _init(reference_rb:RigidBody3D, tgt_mgr: Targeting_manager):
	base_rigidbody = reference_rb
	targeting_manager = tgt_mgr
	targeting_manager.target.connect(_change_target)
	self.update_metrics()

func update_metrics():
	var w_translation
	var w_deltav
	if (base_rigidbody != null):
		var tgt_wpos = targeting_manager.get_wpos()
		if tgt_wpos != null:
			w_translation = targeting_manager.get_wpos() - base_rigidbody.global_position
		else:
			w_translation = Vector3.ZERO

		w_deltav = base_rigidbody.linear_velocity - targeting_manager.get_wvel()

		l_translation_to_target = w_translation * base_rigidbody.global_transform.basis
		l_velocity_to_target = w_deltav * base_rigidbody.global_transform.basis
		l_vtt_sag = l_velocity_to_target.project(l_translation_to_target.normalized())
		l_vtt_sag_pos_len = clamp(l_velocity_to_target.dot(l_translation_to_target.normalized()),0.0,9999999.0)
		l_vtt_tan = l_velocity_to_target - l_vtt_sag
		

func _change_target(target):


	# finally retrigger calcs
	self.update_metrics()
