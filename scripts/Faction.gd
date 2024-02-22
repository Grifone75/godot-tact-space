class_name Faction extends Resource

@export var name : String = ""

@export var main_color : Color
@export var color_dark : Color
@export var color_utility : Color
@export var color_complement : Color


var NAMES = ['The Soldiers of the Lake','The Lancers of the Maple','The Knights of the Sanguine','The Hydra League','The Nightfall Soldiers','The Valiant Helmets','The Sister Order','The Lancers of Guidance','The Knights of Time','The Circle of Heroism','The Helmets of the Bridge','The Order of the Beast','The Guardians of the Voyage','The Crescent Helmets','The Chalice Order','The Salt Soldiers','The Dawn Circle','The Guardians of Knowledge','The League of Autumn','The Templars of Gold','The Helmets of the Circle','The Lancers of the Ice','The Guardians of the Fist','The Light Helmets','The Fire Order','The Night Lancers','The Banner Order','The Legion of Valor','The Squires of Spirit','The Legion of Guidance','The Circle of the Arachnid','The Templars of the Flower','The Circle of the Voyage','The Solitude Knights','The Brass Order','The Infinity Order','The Sanguine Order','The Legion of Battle','The Lancers of Honor','The Preservers of Exaltation']

func _init():
	randomize()
	#chose faction colours
	main_color = [
		#low saturated, light tone (pastel)
		Color.from_ok_hsl(randf_range(0.0,1.0),randf_range(0.1,.5),randf_range(.6,.9)),
		#high saturated, dark
		Color.from_ok_hsl(randf_range(0.0,1.0),randf_range(0.7,1.),randf_range(.1,.4)),
		# hi saturated, vivid
		Color.from_ok_hsl(randf_range(0.0,1.0),randf_range(0.7,1.),randf_range(.5,.8))
		].pick_random()
	color_dark = main_color.darkened(.7)
	color_complement = [
		#hue variant of main 120 degrees, 150% more saturated, light
		Color.from_hsv(fmod(main_color.h+.333,1.),main_color.s*1.5,.2),
		Color.from_hsv(fmod(main_color.h-.333,1.),main_color.s*1.5,.2),
		#opposite hue than main, same sat, light - nice
		Color.from_hsv(fmod(main_color.h+.5,1.),main_color.s,.3),
		#hue variant of main, 50% as saturated, dark - nice
		Color.from_hsv(fmod(main_color.h+randf_range(-0.1,0.1),1.),main_color.s*0.5,.8)
		].pick_random()
	var utilities = [Color("f0b31a"),Color("ff8c1a"),Color("ffe400"),Color("e7c2d2"),Color("101010"), Color.from_hsv(fmod(main_color.h+.5,1.),.9,.7)]
	#col_utility = utilities[0]
	#var opp_hue = col.h + 0.5
	#if opp_hue > 1: opp_hue -= 1.
	#col_utility = Color.from_ok_hsl(opp_hue,.9,.5)
	color_utility = utilities.pick_random()

	name = NAMES.pick_random()



