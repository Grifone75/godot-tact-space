extends Node3D

# reposition the star so that it is always visible but manage the distance.
# also adapt directional light
@export var visual:Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	visual.global_position = (self.global_position).limit_length(30)	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $/root/base.followed_vessel and $/root/base.followed_vessel.rb:
		#we can approximate that in far reference coords the player vessel is always at 0,0,0
		visual.global_position = (self.global_position - $/root/base.followed_vessel.rb.global_position/10000).limit_length(30)
		

func manage_origin_shift(shift):
	global_position -= shift

	if $/root/base.followed_vessel and $/root/base.followed_vessel.rb:
		#we can approximate that in far reference coords the player vessel is always at 0,0,0
		visual.global_position = (self.global_position - $/root/base.followed_vessel.rb.global_position/10000).limit_length(30)
