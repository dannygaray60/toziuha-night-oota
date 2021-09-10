extends KinematicBody2D

var cE = load("res://scripts/enemy.gd").new()


#var id = "boss_big_bat"
#al ser true mandará señal de que el nivel ha terminado una vez finalizado la animacion de muerte
export var final_boss = false

#cuando el jefe muere se puede colocar el nombre de la siguiente escena que se cargará
#dejar vacío para que se mande a la pantalla de resultados de misión
#solo válido cuando final_boss sea true
export var custom_next_scene_on_death = ""

#var hp_max = Vars.enemy[id]["hp_max"]
#var hp_now = hp_max

var anim_state_machine

#var state = "flying"

func _ready():
	
	cE.set_vars("boss_big_bat")
	
	cE.check_boss_doors()

	#Enemy.connect("collision_with_player",self,"_on_collision_with_player")
	anim_state_machine = $AnimationTree.get("parameters/playback")

func hurt(_total_atk,_global_position):
	#muerte de jefe
	if cE.hp_now > 0:
		
		Audio.stop_music()
		
		Vars.player["defeated_bosses"].append(name)
		
		cE.hp_now = 0
		Audio.play_sfx("hit4")
		

		cE.open_doors_on_boss_death(self)
			
		cE.add_boss_orb($PosSpawnOrb.global_position,self,custom_next_scene_on_death)
		
#		visible = false	
		queue_free()





	
