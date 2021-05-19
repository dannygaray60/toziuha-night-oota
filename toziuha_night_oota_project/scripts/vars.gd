extends Node

#----- variables globales, no necesarias en un archivo de partida

#guardar hacia que lado mira el jugador (izq: -1 . der: 1)
#si se deja en cero, el facing será el predeterminado en el script del player
var player_facing = 0
#nombre de la puerta en donde aparecerá
var player_door_spawn = ""

#la ruta a la carpeta del nivel que se está jugando
var level_dir_path = ""

#nombre de la escena principal del nivel a jugar
var level_main_scene = ""

#diccionario con las habitaciones del nivel, cada habitacion con un array
var map_rooms = {}

#variable para almacenar la escena del mapa
var map_object = null

#el jugador a cargado desde savefile de estatua?
var loaded_from_statue_save = false

#el jugador esta en una plataforma que permite bajarse de ella? (one way collision)
var is_on_onewaycollisionplatform = false

#lista de subarmas
var subweapons = {
	"none":{
		"name": "None",
		"atk_add": 0,
		"em_use": 0,
		"description": ".",
	},
	"shuriken":{
		"name": "Shuriken",
		"atk_add": 10,
		"em_use": 1,
		"description": "Shuriken ninja.",
	},
	
	"axe":{
		"name": "Axe",
		"atk_add": 20,
		"em_use": 3,
		"description": "Hacha grande.",
	},
}

#lista de enemigos y todos sus stats
var enemy = {
	"skeleton":{
		"name": "SKELETON",
		"atk": 17,
		"def":2,
		"hp_max": 7,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none","money_10","money_100","money_1","money_1","money_10","money_10"],
	},
	"infected_skeleton":{
		"name": "INFECTEDSKELETON",
		"atk": 17,
		"def":2,
		"hp_max": 7,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none","money_10","money_100","money_1","money_1","money_10","money_10"],
	},
	
	"zombie":{
		"name": "ZOMBIE",
		"atk": 10,
		"def":0,
		"hp_max": 5,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none","money_10","money_100","money_1","money_1","money_10","money_10"],
	},
	"slime":{
		"name": "Slime",
		"atk": 15,
		"def":3,
		"hp_max": 7,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none","money_10","money_100","money_1","money_1","money_10","money_10"],
	},
	"floating_skull":{
		"name": "FLOATINGSKULL",
		"atk": 15,
		"def":3,
		"hp_max": 7,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none"],
	},
	"infected_slime":{
		"name": "INFECTEDSLIME",
		"atk": 15,
		"def":3,
		"hp_max": 7,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none","money_10","money_100","money_1","money_1","money_10","money_10"],
	},
	"demon_skull_head":{
		"name": "DEMONSKULLHEAD",
		"atk": 10,
		"def":3,
		"hp_max": 7,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none"],
	},
	"blood_bat":{
		"name": "BLOODBAT",
		"atk": 10,
		"def":3,
		"hp_max": 7,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none"],
	},
	"bat":{
		"name": "BAT",
		"atk": 7,
		"def":0,
		"hp_max": 2,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none"],
	},
	"cursed_hound":{
		"name": "CURSEDHOUND",
		"atk": 7,
		"def":0,
		"hp_max": 2,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none"],
	},
	"fireball":{
		"name": "",
		"atk": 20,
		"def":0,
		"hp_max": 0,
		"description": "",
		"item_drop": [],
	},
	"boss_big_bat":{
		"name": "BIGBAT",
		"atk": 30,
		"def":3,
		"hp_max": 30,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none"],
	},
	
}

var player = {}

func _ready():
	
	#arreglo para mi control generico de PS2
	Input.add_joy_mapping("030000004c0500006802000000000000,Generic PS3 Controller Custom,platform:Windows,a:b14,b:b13,x:b15,y:b12,back:b1,start:b2,leftstick:-a0,rightstick:+a2,leftshoulder:b10,rightshoulder:b11,dpup:b4,dpdown:b6,dpleft:b7,dpright:b5,-leftx:+a1,+leftx:+a0,-lefty:-a1,-rightx:-a2,righty:a3,lefttrigger:b8,righttrigger:b9,", true)

	var Conf = load("res://scripts/config.gd").new()
	Conf.check_configfile()

	set_vars()

func set_vars():
	
	player_facing = 0
	player_door_spawn = ""

	player = {
		#cual subarma se tiene o "none"
		"subweapon": "none",
		#condicion: good, poison, cursed, healing
		"condition":"good",
		#money
		"money":0,
		#attack and defense
		"atk" : 5,
		"def" : 0,
		#level of weapon
		"weapon_lvl":1,
		#health points
		"hp_now" : 50,
		"hp_max" : 50,
		#elemental materials, munition to throw subweapon
		"em_now" : 0,
		"em_max" : 10,
		#hacia qué lado mira el jugador: -1 : izquierda, 1 : derecha
		"facing" : 1,
		#cantidad maxima de pociones para llevar
		"potion_max": 5,
		#y la cantidad actual
		"potion_now": 0,
		#cantidad de hp que puede dar la pocion
		#calculado en script del jugador
		"potion_healing_hp": 0,
		#habilidad para dar un doble salto
		"hability_double_jump" : false,
		#habilidad para esquivar
		"hability_backdash" : false,
		#deslizarse en el suelo
		"hability_slide" : false,
		#llaves para desbloquear puertas especiales
		"bronze_key": false,
		"silver_key": false,
		"golden_key": false,
		#id de habitacion en la que se encuentra
		"current_room": "",
		#id de habitaciones visitadas
		"visited_rooms": [],
		#id de los items que aumentan estadiscicas
		"upgrade_items": [],
		#(nombre de la escena) de los bosses eliminados
		"defeated_bosses": [],
		
	}


