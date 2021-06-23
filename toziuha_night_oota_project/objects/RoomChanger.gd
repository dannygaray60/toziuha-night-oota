extends Area2D

var f = File.new()

export var destiny_filename = ""
export var destiny_door = ""

func _ready():
	$TimerDontDetect.start()
	
	#obtener al jugador y colocarlo delante de la puerta en caso de...
	var player = get_tree().get_nodes_in_group("player")

	#si hay jugador y hay una puerta a spawnear y la puerta coincide
	if player.size() == 1 and Vars.player_door_spawn != "" and Vars.player_door_spawn == name:
		player[0].global_position = $PositionSpawn.global_position
	else:
		player = null
	
	


func _on_RoomChanger_body_entered(body):
	
	if destiny_filename != "" and body.is_in_group("player") and $TimerDontDetect.get_time_left() == 0:
		body.can_move = false
		
		var go_to = "%s/%s.tscn" % [Vars.level_dir_path,destiny_filename]
		
		#si el campo en vez de ser el nombre del archivo es una ruta completa al archivo
		if destiny_filename.is_abs_path():
			go_to = destiny_filename
		
		if f.file_exists(go_to):
			#deshabilitar input (no funciona)
			#body.set_process_input(false)
			Vars.player_door_spawn = destiny_door
			SceneChanger.change_scene(go_to)
		else:
			print("The file: %s doesn't exists"%[go_to])
