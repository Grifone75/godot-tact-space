extends Node

var is_active
@export var hud_panel: Container
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_active(is_active):
	is_active = is_active
	if hud_panel != null:
		if is_active:
			hud_panel.visible = true
		else:
			hud_panel.visible = false


