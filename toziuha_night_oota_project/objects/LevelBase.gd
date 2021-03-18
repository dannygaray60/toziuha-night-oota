extends Node

var player = null

func _ready():
	
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
	player.connect("stamina_loss",self,"_on_stamina_loss")
	
	#comprobar stamina al inicio y recuperarla
	if Vars.player["sp_now"] < Vars.player["sp_max"]:
		_on_stamina_loss()


#cuando jugador pierde stamina
func _on_stamina_loss():
	$Hud.update_stats()
	$TimerStaminaRecover.start()

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
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

#recuperar stamina de poco a poco
func _on_TimerStaminaRecover_timeout():
	
	if Vars.player["sp_now"] >= Vars.player["sp_max"]:
		$TimerStaminaRecover.stop()
		return

	if player.state in ["idle","crouch","fall","run"]:
		Vars.player["sp_now"] += 1
		$Hud.update_stats()
