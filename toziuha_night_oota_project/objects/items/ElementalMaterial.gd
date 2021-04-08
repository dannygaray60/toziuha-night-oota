extends RigidBody2D

var num = 1

func _ready():
	if num == 1:
		$Sprite.frame = 0
	else:
		$Sprite.frame = 1

func _on_AreaPick_body_entered(body):
	if body.is_in_group("player"):
		
		#si el jugador ya no puede llevar mas pociones
		if Vars.player["em_now"] == Vars.player["em_max"]:
			pass
		else:
			if num == 1:
				Functions.show_hud_notif(tr("IRONPLUS1"))
				Vars.player["em_now"] += 1
				Audio.play_sfx("em_drop")
			else:
				Functions.show_hud_notif(tr("IRONPLUS5"))
				Vars.player["em_now"] += 5
				Audio.play_sfx("em_drop2")
			#la señal stats_changed del jugador hace que los valores del hud se actualicen
			#por lo que lo usaremos para mostrar la cantidad de pociones
			body.emit_signal("stats_changed")
			queue_free()
