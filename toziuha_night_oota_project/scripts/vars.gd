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

#si el control vibrará
var joy_vibrate = true

#lista de subarmas
var subweapons = {
	"none":{
		"name": "None",
		"atk_multiplier": 0,
		"mp_use": 0,
		"description": ".",
	},
	"shuriken":{
		"name": "Shuriken",
		"atk_multiplier": 2,
		"mp_use": 1,
		"description": "Shuriken ninja.",
	},
	
	"axe":{
		"name": "Axe",
		"atk_multiplier": 4,
		"mp_use": 3,
		"description": "Hacha grande.",
	},
}

#lista de circuitos elementales
var elemental_circuits = {
	"hability_double_jump" : {
		"name" : "UNK",
		"description" : "",
		"passive" : true, #false si el circuito es para un ataque especial (y no habilidad pasiva)
		"frame_icon": 0,
	},
	"hability_dodge" : {
		"name" : "UNK",
		"description" : "",
		"passive" : true, #false si el circuito es para un ataque especial (y no habilidad pasiva)
		"frame_icon": 1,
	},
	"hability_slide" : {
		"name" : "UNK",
		"description" : "",
		"passive" : true, #false si el circuito es para un ataque especial (y no habilidad pasiva)
		"frame_icon": 2,
	},
	"hability_circle_whip" : {
		"name" : "UNK",
		"description" : "",
		"passive" : true, #false si el circuito es para un ataque especial (y no habilidad pasiva)
		"frame_icon": 4,
	},
	"hability_hook_whip" : {
		"name" : "UNK",
		"description" : "",
		"passive" : true, #false si el circuito es para un ataque especial (y no habilidad pasiva)
		"frame_icon": 3,
	},
	"whip_lvl_2" : {
		"name" : "UNK",
		"description" : "",
		"passive" : true, #false si el circuito es para un ataque especial (y no habilidad pasiva)
		"frame_icon": 5,
	},
	"whip_lvl_3" : {
		"name" : "UNK",
		"description" : "",
		"passive" : true, #false si el circuito es para un ataque especial (y no habilidad pasiva)
		"frame_icon": 6,
	},
	#sin circuito
	"none" : {
		"name" : "",
		"description" : "",
		"passive" : false, #false si el circuito es para un ataque especial (y no habilidad pasiva)
		"frame_icon": 24,
		"time": 0, #tiempo necesario para usar circuito, 0 significa también pasivo
		"mp_cost": 0, #costo de maná
	},
	#circuitos que son de poderes especiales (circuitos no pasivos)
	"hydro_amnis" : {
		"name" : "Hydro Amnis",
		"description" : "DESC_HYDROAMNIS",
		"passive" : false, #false si el circuito es para un ataque especial (y no habilidad pasiva)
		"frame_icon": 7,
		"time": 1, #tiempo necesario para usar circuito, 0 significa también pasivo
		"mp_cost": 8, #costo de maná
	},
	"vita_pecunia" : {
		"name" : "Vita Pecunia",
		"description" : "DESC_VITAPECUNIA",
		"passive" : false, #false si el circuito es para un ataque especial (y no habilidad pasiva)
		"frame_icon": 8,
		"time": 1, #tiempo necesario para usar circuito, 0 significa también pasivo
		"mp_cost": 10, #costo de maná
	},
	"fulgur_sphaera" : {
		"name" : "Fulgur Sphaera",
		"description" : "DESC_FULGURSPHAERA",
		"passive" : false, #false si el circuito es para un ataque especial (y no habilidad pasiva)
		"frame_icon": 9,
		"time": 1, #tiempo necesario para usar circuito, 0 significa también pasivo
		"mp_cost": 5, #costo de maná
	},
	
	
	
	
}


#lista de objetos equipables (elementos y otros items)
var equipable_items = {
	"none" : {
		"name" : "",
		"description" : "",
		"element" : false, #true si es elemento quimico, false si es objeto equipable
		"frame_icon": 47,
	},
	"melonpan" : {
		"name" : "Melonpan",
		"description" : "A delicious melonpan.",
		"element" : false, #true si es elemento quimico, false si es objeto equipable
		"frame_icon": 0,
	},
	"o" : {
		"name" : "OXYGEN",
		"description" : "DESC_OXYGEN",
		"element" : true, #true si es elemento quimico, false si es objeto equipable
		"frame_icon": 1,
	},
	"cu" : {
		"name" : "COPPER",
		"description" : "DESC_COPPER",
		"element" : true, #true si es elemento quimico, false si es objeto equipable
		"frame_icon": 2,
	},
	"ir" : {
		"name" : "IRIDIUM",
		"description" : "DESC_IRIDIUM",
		"element" : true, #true si es elemento quimico, false si es objeto equipable
		"frame_icon": 4,
	},
	"ti" : {
		"name" : "TITANIUM",
		"description" : "DESC_TITANIUM",
		"element" : true, #true si es elemento quimico, false si es objeto equipable
		"frame_icon": 3,
	},
}

#lista de enemigos y todos sus stats
var enemy = {
	"skeleton":{
		"name": "SKELETON",
		"atk": 9,
		"def":2,
		"hp_max": 7,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none","money_10","money_100","money_1","money_1","money_10","money_10"],
	},
	"infected_skeleton":{
		"name": "INFECTEDSKELETON",
		"atk": 11,
		"def":2,
		"hp_max": 7,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none","money_10","money_100","money_1","money_1","money_10","money_10"],
	},
	"zombie":{
		"name": "ZOMBIE",
		"atk": 5,
		"def": 0,
		"hp_max": 5,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none","money_10","money_100","money_1","money_1","money_10","money_10"],
	},
	"slime":{
		"name": "Slime",
		"atk": 9,
		"def":2,
		"hp_max": 7,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none","money_10","money_100","money_1","money_1","money_10","money_10"],
	},
	"cursed_hound":{
		"name": "CURSEDHOUND",
		"atk": 29,
		"def":0,
		"hp_max": 2,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none"],
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
	"blood_bat":{
		"name": "BLOODBAT",
		"atk": 7,
		"def":0,
		"hp_max": 2,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none"],
	},
	"blood_skeleton":{
		"name": "BLOODSKELETON",
		"atk": 8,
		"def":0,
		"hp_max": 1,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none"],
	},
	"floating_skull":{
		"name": "FLOATINGSKULL",
		"atk": 11,
		"def":1,
		"hp_max": 12,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none"],
	},
	"demon_skull_head":{
		"name": "DEMONSKULLHEAD",
		"atk": 9,
		"def":3,
		"hp_max": 7,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none"],
	},
	"thrower_skeleton":{
		"name": "THROWERSKELETON",
		"atk": 15,
		"def":2,
		"hp_max": 7,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none","money_10","money_100","money_1","money_1","money_10","money_10"],
	},	
	"armored_skeleton":{
		"name": "ARMOREDSKELETON",
		"atk": 20,
		"def":6,
		"hp_max": 30,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none"],
	},
	"infected_slime":{
		"name": "INFECTEDSLIME",
		"atk": 10,
		"def":3,
		"hp_max": 7,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none","none","none","money_10","money_100","money_1","money_1","money_10","money_10"],
	},



	"fireball":{
		"name": "",
		"atk": 10,
		"def":0,
		"hp_max": 1,
		"description": "",
		"item_drop": [],
	},
	"curved_axe":{
		"name": "",
		"atk": 25,
		"def":0,
		"hp_max": 1,
		"description": "",
		"item_drop": [],
	},
	"large_spikes":{
		"name": "",
		"atk": 20,
		"def":0,
		"hp_max": 1,
		"description": "",
		"item_drop": [],
	},
	"small_spikes":{
		"name": "",
		"atk": 13,
		"def":0,
		"hp_max": 1,
		"description": "",
		"item_drop": [],
	},
	"circle_saw":{
		"name": "",
		"atk": 15,
		"def":0,
		"hp_max": 1,
		"description": "",
		"item_drop": [],
	},
	"eva_proyectile1":{
		"name": "",
		"atk": 25,
		"def":0,
		"hp_max": 1,
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
	
	"boss_eva1":{
		"name": "EVA",
		"atk": 28,
		"def":12,
		"hp_max": 1000,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none"],
	},
	"puppet_master":{
		"name": "PUPPETMASTER",
		"atk": 30,
		"def":22,
		"hp_max": 1200,
		"description": "Description...",
		#y aqui una lista de objetos que puede dejar al morir...
		"item_drop": ["none"],
	},
	
	
}

var player = {}

func _ready():

	var Conf = load("res://scripts/config.gd").new()
	Conf.check_configfile()

	set_vars()

func set_vars():
	
	player_facing = 0
	player_door_spawn = ""

	player = {
		#cuantas veces murió jugador en una misión
		"deaths": 0,
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
		#mana points, munition to throw subweapon
		"mp_now" : 0,
		"mp_max" : 10,
		#stamina points (for run, backdash, dodge)
		"sp_now" : 100,
		"sp_max" : 100,
		#hacia qué lado mira el jugador: -1 : izquierda, 1 : derecha
		"facing" : 1,
		#cantidad maxima de pociones para llevar
		"potion_max": 2,
		#y la cantidad actual
		"potion_now": 0,
		#cantidad de hp que puede dar la pocion
		"potion_healing_hp": 0, #calculado en script del jugador
		#habilidad para dar un doble salto
		"hability_double_jump" : false,
		#habilidad para esquivar
		"hability_dodge" : false,
		#deslizarse en el suelo
		"hability_slide" : false,
		#habilidad para colgarse del latigo
		"hability_hook_whip" : false,
		#habilidad para girar el latigo
		"hability_circle_whip" : false,
		#llaves para desbloquear puertas especiales
		"bronze_key": false,
		"silver_key": false,
		"golden_key": false,
		#id de habitacion en la que se encuentra
		"current_room": "",
		#index del circuito equipado
		"current_circuit": 0, #
		#id del elemento (aleación), u objeto equipado 
		"current_element_item": 0, #
		#id de circuitos obtenidos
		"elemental_circuits": ["none"],
		#id de elementos obtenidos
		"elements_items": ["none"],
		#id de habitaciones visitadas
		"visited_rooms": [],
		#id de los items que aumentan estadiscicas
		"upgrade_items": [],
		#(nombre de la escena) de los bosses eliminados
		"defeated_bosses": [],
		#añadir cualquier string que sirva como flag (si está es true, si no es false)
		"flags" : [],
		
	}


