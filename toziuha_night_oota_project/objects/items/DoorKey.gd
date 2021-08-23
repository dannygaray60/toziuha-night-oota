extends RigidBody2D

export(String, "bronze_key", "silver_key", "golden_key") var item = "bronze_key"

func _ready():
	
	#eliminar objeto si el jugador ya lo tiene
	if item in ["double_jump","slide","dodge","circle_whip","hook_whip"]:
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
		"circle_whip":
			$Sprite.frame = 7
		"hook_whip":
			$Sprite.frame = 6
		"bronze_key":
			$Sprite.frame = 3
		"silver_key":
			$Sprite.frame = 4
		"golden_key":
			$Sprite.frame = 5

func _on_AreaPick_body_entered(body):
	if body.is_in_group("player"):
		
		if item in ["double_jump","slide","dodge","circle_whip","hook_whip"]:
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
				"circle_whip":
					body.show_quick_notif(tr("SKILLCIRCLEWHIP"))
				"hook_whip":
					body.show_quick_notif(tr("SKILLHOOKWHIP"))
				"bronze_key":
					body.show_quick_notif(tr("BRONZEKY"))
				"silver_key":
					body.show_quick_notif(tr("SILVERKY"))
				"golden_key":
					body.show_quick_notif(tr("GOLDENKY"))

		queue_free()
