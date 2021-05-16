extends RigidBody2D

var orb = preload("res://objects/OrbBoss.tscn")
var orb_instance = null

var dead = false

#al ser true mandará señal de que el nivel ha terminado una vez finalizado la animacion de muerte
export var final_boss = false

func _ready():
	
	if name in Vars.player["defeated_bosses"]:
		for d in get_tree().get_nodes_in_group("special_door"):
			d.keep_open_door = true
		queue_free()

func hurt(_total_atk,_global_position):
	if !dead:
		
		Vars.player["defeated_bosses"].append(name)
		
		dead = true
		Audio.play_sfx("hit4")
		
		#solo se abrirán puertas si no es jefe final
		#en consecuencia su orbe no aparecerá de nuevo si se regresa a la habitacion
		if !final_boss:
			for d in get_tree().get_nodes_in_group("special_door"):
				d.open_door(true)
			
		orb_instance = orb.instance()
		orb_instance.global_position = $PosSpawnOrb.global_position
		orb_instance.end_of_level = final_boss
		
		Functions.get_main_level_scene().call_deferred("add_child",orb_instance)
			
		queue_free()
