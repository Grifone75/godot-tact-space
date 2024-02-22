extends VBoxContainer

@export var element_template:PackedScene

var cached_element_list = []

# Called when the node enters the scene tree for the first time.
func _ready():
	cyclic_update_order()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func populate(feed_list):
	for el in feed_list:
		var line = element_template.instantiate()
		add_child(line)
		cached_element_list.append(line)
		line.setup(el)
	sort_list()

func cyclic_update_order():
	while true:
		sort_list()
		await get_tree().create_timer(.5).timeout
				
func sort_list():
	var items = get_children()
	if items:
		items.sort_custom(func(a,b): return a.connected_node.get_distance.call() < b.connected_node.get_distance.call() )
		for i in items.size():
			move_child(items[i],i)

func clear():
	for el in cached_element_list:
		el.free()
	cached_element_list = []
	

	
