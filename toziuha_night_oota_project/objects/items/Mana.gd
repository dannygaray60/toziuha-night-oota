extends RigidBody2D

#la cantidad de em a agregar
var num = 1

func _ready():
	if num == 1:
		$Sprite.frame = 0
	else:
		$Sprite.frame = 1

func _on_AreaPick_body_entered(body):
	if body.is_in_group("player"):
		
		#si el jugador ya no puede llevar mas pociones
		if Vars.player["mp_now"] == Vars.player["mp_max"]:
			pass
		else:
			if num == 1:
				Functions.show_hud_notif(tr("MPPLUS1"))
				Vars.player["mp_now"] += 1
				Audio.play_sfx("mp_drop")
			else:
				Functions.show_hud_notif(tr("MPPLUS5"))
				Vars.player["mp_now"] += 5
				Audio.play_sfx("mp_drop2")
				#quitar excedente
				if Vars.player["mp_now"] > Vars.player["mp_max"]:
					Vars.player["mp_now"] = Vars.player["mp_max"]
			#la señal stats_changed del jugador hace que los valores del hud se actualicen
			#por lo que lo usaremos para mostrar la cantidad de pociones
			body.emit_signal("stats_changed")
			queue_free()
