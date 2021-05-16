extends RigidBody2D

export(String, "atk","def","hp","em","potion") var stat = "atk"
export(int, 1, 50) var quantity

func _ready():
	
	if name in Vars.player["upgrade_items"] and name != "":
		queue_free()
	
	match stat:
		"atk":
			$Sprite.frame = 1
		"def":
			$Sprite.frame = 2
		"hp":
			$Sprite.frame = 0
		"em":
			$Sprite.frame = 3
		"potion":
			$Sprite.frame = 4

func _on_AreaPick_body_entered(body):
	if body.is_in_group("player"):
		
		if name in Vars.player["upgrade_items"] and name != "":
			return
		
		if stat in ["atk","def"]:
			Vars.player[stat] += quantity
		else:
			#aumentar cantnamead al stat
			Vars.player[stat+"_max"] += quantity
			#si se aumenta capacnamead de vnamea entonces se recupera el total
			if stat == "hp":
				Vars.player[stat+"_now"] = Vars.player[stat+"_max"]
			body.emit_signal("stats_changed")
			
		Audio.play_sfx("weapon_upgrade")
		Vars.player["upgrade_items"].append(name)

		#mostrar habilidad como notificacion rapida
		if body.has_method("show_quick_notif"):
			match stat:
				"atk":
					body.show_quick_notif(tr("ATK")+" +%d"%[quantity])
				"def":
					body.show_quick_notif(tr("DEF")+" +%d"%[quantity])
				"hp":
					body.show_quick_notif(tr("HP")+" +%d"%[quantity])
				"em":
					body.show_quick_notif(tr("EMLIMIT")+" +%d"%[quantity])
				"potion":
					body.show_quick_notif(tr("POTIONLIMIT")+" +%d"%[quantity])
				
#			

		#mostrar mensaje al obtener item
#		match stat:
#			"atk":
#				DialogBox.lines = [['say','none',tr("PHRASEATKINCREASED")%[quantity]],]	
#			"def":
#				DialogBox.lines = [['say','none',tr("PHRASEDEFINCREASED")%[quantity]],]	
#			"hp":
#				DialogBox.lines = [['say','none',tr("PHRASEHPINCREASED")%[quantity]],]	
#			"em":
#				DialogBox.lines = [['say','none',tr("PHRASEEMINCREASED")%[quantity]],]	
#			"potion":
#				DialogBox.lines = [['say','none',tr("PHRASEPOTIONINCREASED")%[quantity]],]	
#		DialogBox.show_panel("purple_light")

		queue_free()
