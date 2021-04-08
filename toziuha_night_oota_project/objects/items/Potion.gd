extends RigidBody2D



func _on_AreaPick_body_entered(body):
	if body.is_in_group("player"):
		
		#si el jugador ya no puede llevar mas pociones
		if Vars.player["potion_now"] == Vars.player["potion_max"]:
			pass
		else:
			Functions.show_hud_notif(tr("POTION"))
			Vars.player["potion_now"] += 1
			Audio.play_sfx("item_pick1")
			#la señal stats_changed del jugador hace que los valores del hud se actualicen
			#por lo que lo usaremos para mostrar la cantidad de pociones
			body.emit_signal("stats_changed")
			queue_free()
