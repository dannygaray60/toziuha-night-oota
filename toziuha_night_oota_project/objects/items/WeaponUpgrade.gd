extends RigidBody2D

export(int,2,3) var lvl = 2

func _ready():
	
	#si el jugador ya tiene el maximo nivel del arma
	#o el nivel del upgrade es el mismo al que ya se tiene
	#o el nivel del upgrade es menor al nivel ya obtenido
	if (Vars.player["weapon_lvl"] >= 3) or (Vars.player["weapon_lvl"] == lvl) or (lvl == 2 and Vars.player["weapon_lvl"] == 3):
		queue_free()
		
	
	match lvl:
		2:
			$Sprite.frame = 0
		3:
			$Sprite.frame = 1

func _on_AreaPick_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("show_quick_notif"):
			body.show_quick_notif(tr("WEAPONLVL")%[lvl])
		else:
			Functions.show_hud_notif(tr("WEAPONLVL")%[lvl])
		Audio.play_sfx("weapon_upgrade")
		Vars.player["weapon_lvl"] = lvl
		#saldrá error si en la escena no está el arma del jugador
		#get_tree().get_nodes_in_group("player_main_weapon")[0]._ready()
		body.weapon_change_level(lvl)
		queue_free()
