class_name WideAreaNode extends Node

@export var x : float
@export var y : float
@export var z : float

@export var radius_activation : float = 30000
@export var radius_deactivation : float = 31000

@export var entities = []

@export var transiting_entities = []

@onready var gizmo = $debug_gizmo

var approx_position: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	gizmo.global_position = Vector3(x/10000,y/10000,z/10000)
	gizmo.get_node("Draw3D").circle_XZ(Vector3.ZERO,radius_activation/10000)
	gizmo.get_node("Draw3D").circle_XY(Vector3.ZERO,radius_activation/10000)
	approx_position = Vector3(x,y,z)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
	
