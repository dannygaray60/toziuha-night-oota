extends RigidBody2D

export(String, "double_jump","backdash","slide", "bronze_key", "silver_key", "golden_key") var item = "double_jump"

func _ready():
	
	#eliminar objeto si el jugador ya lo tiene
	if item in ["double_jump","slide","backdash"]:
		if Vars.player["hability_"+item]:
			queue_free()
	elif Vars.player[item]:
		queue_free()

	match item:
		"double_jump":
			$Sprite.frame = 0
		"slide":
			$Sprite.frame = 1
		"backdash":
			$Sprite.frame = 2
		"bronze_key":
			$Sprite.frame = 3
		"silver_key":
			$Sprite.frame = 4
		"golden_key":
			$Sprite.frame = 5

func _on_AreaPick_body_entered(body):
	if body.is_in_group("player"):
		if item in ["double_jump","slide","backdash"]:
			
			Audio.play_sfx("weapon_upgrade")
			Vars.player["hability_"+item] = true
			match item:
				"double_jump":
					DialogBox.lines = [
						['say','none',tr("PHRASE_DOUBLEJUMP")],
					]
				"slide":
					DialogBox.lines = [
						['say','none',tr("PHRASE_SLIDE")],
					]
				"backdash":
					DialogBox.lines = [
						['say','none',tr("PHRASE_BACKDASH")],
					]
			DialogBox.show_panel("purple_light")
		else:
			Audio.play_sfx("em_drop")
			Vars.player[item] = true
			match item:
				"bronze_key":
					Functions.show_hud_notif(tr("BRONZEKY"))
				"silver_key":
					Functions.show_hud_notif(tr("SILVERKY"))
				"golden_key":
					Functions.show_hud_notif(tr("GOLDENKY"))
				

		queue_free()
