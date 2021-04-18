extends Node

#----- variables globales, no necesarias en un archivo de partida

#guardar hacia que lado mira el jugador (izq: -1 . der: 1)
#si se deja en cero, el facing será el predeterminado en el script del player
var player_facing = 0
#nombre de la puerta en donde aparecera 
var player_door_spawn = ""

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
		"description": "Description..."
		#y aqui una lista de objetos que puede dejar al morir...
	},
	"zombie":{
		"name": "ZOMBIE",
		"atk": 10,
		"hp_max": 5,
		"description": "Description..."
		#y aqui una lista de objetos que puede dejar al morir...
	},
	"slime":{
		"name": "Slime",
		"atk": 15,
		"def":3,
		"hp_max": 7,
		"description": "Description..."
		#y aqui una lista de objetos que puede dejar al morir...
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
		"potion_healing_hp": 2,
		#habilidad para dar un doble salto
		"hability_double_jump" : false,
		#habilidad para esquivar
		"hability_backdash" : false,
		#deslizarse en el suelo
		"hability_slide" : false,
		#llaves para desbloquear puertas especiales
		"bronce_key": false,
		"silver_key": false,
		"golden_key": false,
		
	}


