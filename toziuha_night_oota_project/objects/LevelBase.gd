extends Node

export(String, "silence","rondo_of_darkness","nameless_symphony", "cave_theme") var music

var player = null

func _ready():
	
	if music == "silence":
		Audio.stop_music()
	else:
		Audio.play_music(music)
	
	#obtener al jugador
	player = get_tree().get_nodes_in_group("player")
	
	#si no se ha agredado un solo jugador...
	if player.size() != 1:
		print("Please Add a playable character")
		return
	
	#get the player's node
	player = player[0]
	#connect signals
	player.connect("damaged",self,"_on_player_damage")
	player.connect("dead",self,"_on_player_death")
	player.connect("stats_changed",self,"_on_stats_changed")


#cuando jugador pierde stamina
func _on_stats_changed():
	$Hud.update_stats()

#al ser dañado
func _on_player_damage():
	$Hud.update_stats()

#al morir
func _on_player_death():
	$FadeBlack/Tween.interpolate_property($FadeBlack/ColorRect,"color",Color(0,0,0,0),Color(0,0,0,1),5,
	Tween.TRANS_LINEAR,Tween.TRANS_LINEAR)
	$FadeBlack/Tween.start()

#cuando terminó el fade al morir
func _on_Tween_tween_all_completed():
	Vars.set_vars()
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

#mostrar botones tactiles de acuerdo a configuracion
func _on_LevelBase_ready():
	ControlsOnscreen.show_buttons_in_game()
