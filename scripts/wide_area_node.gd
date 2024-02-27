@tool
class_name WideAreaNode extends Node3D

@export var x : float
@export var y : float
@export var z : float

@export var radius_activation : float = 400000
@export var radius_deactivation : float = 410000

@export var entities = []

@export var transiting_entities = []

@onready var gizmo = $debug_gizmo
@export var hud_marker : Node2D

var approx_position: Vector3
var gizmo_position = Vector3.ZERO

#temp code to test station spawning
var station_spawned = false

# Called when the node enters the scene tree for the first time.
func _ready():
	gizmo.get_node("Draw3D").circle_XZ(Vector3.ZERO,radius_activation/10000)
	gizmo.get_node("Draw3D").circle_XZ(Vector3(0,radius_activation/10000/2,0),radius_activation/10000*.8)
	gizmo.get_node("Draw3D").circle_XZ(Vector3(0,-radius_activation/10000/2,0),radius_activation/10000*.8)
	#gizmo.get_node("Draw3D").circle_XY(Vector3.ZERO,radius_activation/10000)
	approx_position = self.global_position * 10000

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if !Engine.is_editor_hint():
		if $/root/base:
		#test code to see if we can disaply wide area nodes using the hud
			hud_marker.show()
			if (get_viewport().get_camera_3d().is_position_behind(approx_position)):
				hud_marker.hide()
			else:
				hud_marker.show()
				var screen_pos = get_viewport().get_camera_3d().unproject_position(approx_position)
				hud_marker.position = screen_pos
	
func manage_origin_shift(shift):
	#approx_position -= shift*10000.0
	#gizmo.get_node("Draw3D").clear()
	global_position -= shift
	approx_position = global_position * 10000.0
	#gizmo.get_node("Draw3D").circle_XZ(gizmo_position,radius_activation/10000)
	#gizmo.get_node("Draw3D").circle_XY(gizmo_position,radius_activation/10000)
	
	
	#update the visual representation of the node
	
func on_player_inside():
	#TODO change, this is test code
	#print("player inside ", self.name)
	if not station_spawned:
		var a = load("res://scenes/station.tscn").instantiate()
		var faction = Faction.new()
		if "vessels" in a.get_groups():
			a.faction = faction
		$/root/base/SubViewportContainer/SubViewport_objects.add_child.call_deferred(a) # get_tree().get_root()
		a.initial_position = self.approx_position + Vector3(randf_range(100,2000),randf_range(100,2000),randf_range(100,2000))
		if a.has_method("update_label"): a.update_label("station test")
		if a.has_method("materialize"): a.call_deferred("materialize")
		station_spawned = true


func on_player_outside():
	#print("player outside ", self.name)
	pass
