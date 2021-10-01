extends Node

export var enable_quicksave = true

#titulo de la habitacion que se mostrará una vez como titulo
#dejar vacío para no mostrar nada
export var title_room = ""

export(String, "silence","the_beginning_of_darkness", "caverns_theme", "cave_theme", "the_mystic_forest", "ambient_forest_wind") var music = "silence"

var player = null

func _ready():
	
	$Hud.can_quicksave = enable_quicksave
	
	get_player()

	#obtener el path de la escena, luego el archivo, 
	#despues se elimina la extensión para solo tener el nombre de archivo
	Vars.player["current_room"] = get_tree().current_scene.filename.get_file().replace(".tscn","")

	if music == "silence":
		Audio.stop_music()
	else:
		Audio.play_music(music)

	#dar un poco de tiempo antes de mostrar cartel
	$Timer.start()
	yield($Timer,"timeout")
	if Vars.player["current_room"] in Vars.player["visited_rooms"]:
		pass
	elif Vars.player["current_room"] != "":
		#agregar id de habitacion a diccionario de habitaciones visitadas
		Vars.player["visited_rooms"].append(Vars.player["current_room"])
		if title_room != "":
			$Hud.show_titleroom(title_room)

	#comprobar si hay un archivo map.tscn y agregarlo en
	#ControlPause
	if Vars.map_object != null:
		var map_instance = Vars.map_object.instance()
		$Hud/ControlPause/ControlMap.add_child(map_instance)
		
#obtener la referencia de player como nodo, o retornará null
func get_player():
	if player == null:
		#obtener al jugador
		player = get_tree().get_nodes_in_group("player")
		#si no se ha agredado un solo jugador...
		if player.size() != 1:
			print("Please Add a playable character")
		else:
			#get the player's node
			player = player[0]
			#connect signals
			player.connect("damaged",self,"_on_player_damage")
			player.connect("dead",self,"_on_player_death")
			player.connect("stats_changed",self,"_on_stats_changed")
	return player

#cuando jugador pierde stamina
func _on_stats_changed():
	$Hud.update_stats()

#al ser dañado
func _on_player_damage():
	$Hud.update_stats()

#al morir
func _on_player_death():	
	$FadeBlack/Tween.interpolate_property($FadeBlack/ColorRect,"color",Color(0,0,0,0),Color(0,0,0,1),3,
	Tween.TRANS_LINEAR,Tween.TRANS_LINEAR)
	$FadeBlack/Tween.start()

#cuando terminó el fade al morir
func _on_Tween_tween_all_completed():
	
	#primero obtener el contador de muertes antes de la muerte actual
	var prev_deaths_count = Vars.player["deaths"]	

	#si no hay partida guardada (desde estatua) se reinicia el nivel (y variable player)
	if !Savedata.has_savefile("savegame"):
		Vars.set_vars()
		#despues de reiniciar valores
		#se aumenta contador de muertes con el valor obtenido previamente 
		Vars.player["deaths"] = prev_deaths_count + 1
		SceneChanger.change_scene("%s/%s.tscn"%[Vars.level_dir_path,Vars.level_main_scene])
	else:
		if Savedata.load_savedata("savegame") == OK:
			
			Vars.loaded_from_statue_save = true

			#aumentar contador y guardar valor
			Vars.player["deaths"] += 1
			Savedata.save_savedata("savegame")
			
			SceneChanger.change_scene("%s/%s.tscn"%[Vars.level_dir_path,Vars.player["current_room"]])
	

#mostrar botones tactiles de acuerdo a configuracion
func _on_LevelBase_ready():
	ControlsOnscreen.show_buttons_in_game()

#cuando sale de tree, se oculta controles
func _on_LevelBase_tree_exiting():
#	ControlsOnscreen.show_buttons(false)
	pass
