extends Area2D

var f = File.new()

export var destiny_filename = ""
export var destiny_door = ""

func _ready():
	$TimerDontDetect.start()

	#si hay jugador y hay una puerta a spawnear y la puerta coincide
	#esto no debería pasar si se cargó el escenario desde estatua
	if !Vars.loaded_from_statue_save and Functions.get_main_level_scene().get_player() != null and Vars.player_door_spawn != "" and Vars.player_door_spawn == name:
		Functions.get_main_level_scene().get_player().global_position = $PositionSpawn.global_position
	
	


func _on_RoomChanger_body_entered(body):
	
	#por si acaso el cuerpo del jugador entra estando muerto así evitar que se pueda seguir jugando con 0 de vida
	if Vars.player["hp_now"] <= 0:
		return
	
	if destiny_filename != "" and body.is_in_group("player") and $TimerDontDetect.get_time_left() == 0:
		body.can_move = false
		
		var go_to = "%s/%s.tscn" % [Vars.level_dir_path,destiny_filename]
		
		#si el campo en vez de ser el nombre del archivo es una ruta completa al archivo
		if destiny_filename.is_abs_path():
			go_to = destiny_filename
		
		if f.file_exists(go_to):
			#deshabilitar hitbox de jugador
			body.enable_collision_with_danger(false)
			#deshabilitar input (no funciona)
			#body.set_process_input(false)
			Vars.player_door_spawn = destiny_door
			SceneChanger.change_scene(go_to)
		else:
			print("The file: %s doesn't exists"%[go_to])
