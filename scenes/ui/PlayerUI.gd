extends Node

var is_active = true
@export var hud_panel: Container
# Called when the node enters the scene tree for the first time.
func _ready():
	refresh_contact_list()


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


func refresh_contact_list():
	while is_active:
		$ContactList.clear()
		if $/root/base.followed_vessel and $/root/base.followed_vessel.pilot:
			var contacts = $/root/base.followed_vessel.pilot.update_contact_list()
			$ContactList.populate(contacts)
		await get_tree().create_timer(2.).timeout
