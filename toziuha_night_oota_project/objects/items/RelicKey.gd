extends RigidBody2D

export(String, "double_jump","dodge","slide", "bronze_key", "silver_key", "golden_key") var item = "double_jump"

func _ready():
	
	#eliminar objeto si el jugador ya lo tiene
	if item in ["double_jump","slide","dodge"]:
		if Vars.player["hability_"+item]:
			queue_free()
	elif Vars.player[item]:
		queue_free()

	match item:
		"double_jump":
			$Sprite.frame = 0
		"slide":
			$Sprite.frame = 1
		"dodge":
			$Sprite.frame = 2
		"bronze_key":
			$Sprite.frame = 3
		"silver_key":
			$Sprite.frame = 4
		"golden_key":
			$Sprite.frame = 5

func _on_AreaPick_body_entered(body):
	if body.is_in_group("player"):
		
		if item in ["double_jump","slide","dodge"]:
			Audio.play_sfx("weapon_upgrade")
			Vars.player["hability_"+item] = true
		else:
			Audio.play_sfx("mp_drop")
			Vars.player[item] = true

		#mostrar habilidad como notificacion rapida
		if body.has_method("show_quick_notif"):
			match item:
				"double_jump":
					body.show_quick_notif(tr("SKILLDOUBLEJUMP"))
				"slide":
					body.show_quick_notif(tr("SKILLSLIDE"))
				"dodge":
					body.show_quick_notif(tr("SKILLDODGE"))
				"bronze_key":
					body.show_quick_notif(tr("BRONZEKY"))
				"silver_key":
					body.show_quick_notif(tr("SILVERKY"))
				"golden_key":
					body.show_quick_notif(tr("GOLDENKY"))

		queue_free()
