extends Node

func _ready():
	#arreglo para mi control generico de PS2
	Input.add_joy_mapping("030000004c0500006802000000000000,Generic PS3 Controller Custom,platform:Windows,a:b14,b:b13,x:b15,y:b12,back:b1,start:b2,leftstick:-a0,rightstick:+a2,leftshoulder:b10,rightshoulder:b11,dpup:b4,dpdown:b6,dpleft:b7,dpright:b5,-leftx:+a1,+leftx:+a0,-lefty:-a1,-rightx:-a2,righty:a3,lefttrigger:b8,righttrigger:b9,", true)

#------ Variables globales que también podrán guardarse en archivos de partidas

var player = {
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
	#stamina points
	"sp_now" : 100,
	"sp_max" : 100,
	#elemental materials, munition to throw subweapon
	"em_now" : 5,
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
	"hability_double_jump" : true,
	#correr al doble de velocidad al hacer doble pulsacion en izq o der
	"hability_backdash" : true,
	#deslizarse en el suelo
	"hability_slide" : true
}

#----- variables globales, no necesarias en un archivo de partida

#guardar hacia que lado mira el jugador (izq: -1 . der: 1)
#si se deja en cero, el facing será el predeterminado en el script del player
var player_facing = 0

#el jugador esta en una plataforma que permite bajarse de ella? (one way collision)
var is_on_onewaycollisionplatform = false

#lista de enemigos y todos sus stats
var enemy = {
	"skeleton":{
		"name": "Skeleton",
		"atk": 40,
		"hp_max": 20,
		"description": "Description..."
		#y aqui una lista de objetos que puede dejar al morir...
	}
}

#lista de armas
#var weapons = {
#	"IronWhipL":{
#		"name": "Látigo de cadenas +3",
#		"atk": 20,
#		"stamina_use": 30, #uso de stamina
#		"description": "Látigo de cadenas larga."
#	}
#}

#lista de subarmas
#var subweapons = {
#	"Shuriken":{
#		"name": "Shuriken",
#		"thumb_frame": 1,
#		"atk": 10,
#		"mana_use": 1,
#		"description": "Shuriken ninja.",
#		"res": "res://objects/subweapon_Shuriken.tscn" #path del objeto
#	},
#	"Axe":{
#		"name": "Hacha",
#		"thumb_frame": 2,
#		"atk": 20,
#		"mana_use": 3,
#		"description": "Hacha grande.",
#		"res": "res://objects/subweapon_Axe.tscn"
#	},
#}
