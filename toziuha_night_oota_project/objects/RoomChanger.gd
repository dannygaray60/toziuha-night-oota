extends Area2D

export var destiny_path = ""
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
	
	if body.is_in_group("player") and $TimerDontDetect.get_time_left() == 0:
		#deshabilitar input (no funciona)
		#body.set_process_input(false)
		Vars.player_door_spawn = destiny_door
		SceneChanger.change_scene(destiny_path)
