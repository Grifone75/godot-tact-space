class_name Space_construction_class extends Resource


@export var model_scene_path = "res://data/models/all_ships_and_stations.blend"

@export var root_pattern = "center_[0-9]"

@export var matches = {
	"center_[0-9]":{
		"attach_m_side":["side_2","side_1","side_5", "side_6", "side_4", "side_7"],
		"attach_m_front":["front4_h", "front5_h", "front2_h", "front1"],
		"attach_m.back":["^engine1","enginehub","enginehub2","enginehub3"],
		"attach_mback":["^engine1","enginehub","enginehub2","enginehub3"],
		"attach_m_module_small":["ship_module_scanner","ship_module_omnisensor"],
		"attach_m_weapon":["res://scenes/gun_1.tscn"],
		"attach_m_rcs":["res://scenes/thruster_small.tscn"]	,
	},
	"side_[0-9]":{
		"attach_m_weapon":["res://scenes/gun_1.tscn"]	
	},
	"front[0-9](_h)*":{
		"attach_m_side":["fr_section2_h","fr_section3_h", "fr_section4_h"],
		"attach_m_module_small":["ship_module_scanner"],
		"attach_m_rcs":["res://scenes/thruster_small.tscn"]	,
		"attach_m_signal_light":["res://scenes/signal_light.tscn"],
		"attach_m_cabin01":["res://scenes/cabin_01.tscn"],
		"attach_m_windows":["res://scenes/windows_4.tscn"]
	},
	"fr_section":{
		"attach_m_module_small":["ship_module_omnisensor"],
		"attach_m_rcs":["res://scenes/thruster_small.tscn"],
		"attach_m_windows":["res://scenes/windows_4.tscn"]
	},
	"enginehub[0-9]*":{
		"attach_m_sideengine":{"novarying":"engine", "list":["side_engine1","side_engine2","side_engine3"]},
		"attach_m_rcs":["res://scenes/thruster_small.tscn"]	
	},
	"^engine[0-1]*$":{
		"attach_m_thruster":["res://scenes/thruster.tscn"],
	},
	"side_engine[0-9]*":{
		"attach_m_thruster":["res://scenes/thruster.tscn"],
		"attach_m_rcs":["res://scenes/thruster_small.tscn"]	
	}
	
}


@export var functional_mapping = {
	"res://scenes/thruster.tscn":"thrusters",
	"res://scenes/thruster_small.tscn":"thrusters",
	"res://scenes/gun_1.tscn":"turrets",
	"res://scenes/cabin_01.tscn":"cabins",
	"res://scenes/windows_4.tscn":"cabins"
}



@export var names = [
	{
		"n1":["The Phoenix","The Cascade","The Thunderstorm","The Curator","The Face Of Death","The Stalker","The Brimstone","The Black Talon","The Leech","The Necro","The Homage","The Giant's Fist","The Eventide","The Mongrel","The Curtain's Fall","The Specter","The Storm Cloud","The Requiem","The Bloodlord","The Flame Wall"]
	},
	{
		"n0":["Pride of the ","Nation of the ", "Force of the ", "Gift of the ", "Sword of the ", "Hand of the "],
		"n1":["Etralese","Ashiaonian","Tredalic","Clasteiniot","Yogrurino","Woclurese","Hoslioanian","Jaseno","Stroain","Trieri","Uchurgish","Eglaanian","Scuguaiote","Sheyguaiote","Zecresese","Leblean","Quscii","Lutriene","Skiaite","Scaihasonian","Uwhosene","Aclonite","Shiusauanian","Smoelori","Coshoese","Bawhijaian","Tusnino","Qatrier","Striehonian","Pluypiote"]
	},
	{
		"n0":["Home of ", "", "Eye of "],
		"n1":["The Serpent Raiders","The Berserker Bandits","The Rusty Bandits","The Merpeople Raiders","The Pirates of the North","The Pillagers of the Great Lake","The Bandits of the Plank","The Salty Dogs","The Blackbeards","The Crazy Eyes","The Nightmare Corsairs","The Neptune Raiders","The White Shark Plunderers","The Berserker Pirates","The Bandits of the North","The Pirates of the Black Squid","The Bandits of the Sanguine Flag","The Hired Guns","The Skull and Crossbones","The Shellbacks","The Merpeople Buccaneers","The Mermaid Buccaneers","The Seashell Pirates","The East Sea Rovers","The Buccaneers of the Inner Sea","The Pirates of the Lost Treasure","The Rovers of the Bloodied Flag","The Barnacles","The Black Skulls","The Black Tooth Grins"]
	},
	{
		"n1":["The Aether Soul", "The Devil Blood", "The Blood Blood", "The Evenheart", "The Chaos One", "The Stellar Heart", "The Wondergift", "The Spell Child", "The Virtuechild", "The Fatesoul", "The Frostchild", "The Divine Child", "The Demon Blood", "The Wrath Gift", "The Pure Soul", "The Blood Soul", "The Furor Gift", "The Dead Blood", "The Radiant One", "The Faye Soul "]
	},
	{
		"n1":["Ambystoma","Scorpaenidae","Squalus","Alcelaphinae Major","Scorpaenidae Major","Violet Sheep","Black Trout","Eastern Scarf","Western Horn","Western Robe","Papilionoidea","Sarcophilus","Simia","Oniscidea Borealis","Anguis Occidentalis","Amethyst Rat","Vermilion Trout","Eastern Arrow","Large Telescope","Small Ship","Achatina","Dermaptera","Ramphastos","Dromaius Occidentalis","Enhydra Major","Harlequin Porcupine","Red Goose","Big Brush","Small Airplane","Large Couldron","Cichlidae","Chelonioidea","Rhinoceros","Caeli Orientalis","Dynastes Australis","Emerald Starfish","Violet Kangaroo","Northern Fountain","Eastern Spade","Big Wrench"]
	}
]

@export var initial_mission_path :Script = null

func get_construction_name():
	randomize()
	var name = ""
	for name_group in names.pick_random().values():
		name += name_group.pick_random()
	return name


