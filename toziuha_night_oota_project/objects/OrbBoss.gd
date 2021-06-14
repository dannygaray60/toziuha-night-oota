extends RigidBody2D

#orbe aparecerá sin hacer flash o ruido
export var silent_spawn = false

export var end_of_level = false
export var custom_next_scene = ""

func _ready():
	$Area2DTile.monitoring = false
	if !silent_spawn:
		Audio.play_sfx("boss_orb_generating")
	$AnimationPlayer.play("show")

func flash():
	if !silent_spawn:
		Functions.get_main_level_scene().get_node("Hud").show_flash()
func play_heartbeat():
	if !silent_spawn:
		Audio.play_sfx("boss_orb_heartbeat")
func play_orb_generated():
	if !silent_spawn:
		Audio.play_sfx("boss_orb_generated")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"show":
			$Area2DTile.monitoring = true
			gravity_scale = 2
		"idle":
			pass


func _on_Area2D_body_entered(body):
	
	if body is TileMap:
		$AnimationPlayer.play("idle")

	elif body.is_in_group("player"):
		Audio.stop_music()
		$AnimationPlayer.stop()
		
		if end_of_level:
			
			Functions.get_main_level_scene().get_node("Hud").can_pause = false
			
			body.can_move = false
			body.velocity.x = 0
			body.direction.x = 0
			
			Audio.play_sfx("level_end")
			
			visible = false
			$Timer.start()
			yield($Timer,"timeout")
			if custom_next_scene != "":
				var go_to = "%s/%s.tscn" % [Vars.level_dir_path,custom_next_scene]
				#print("ir a siguiente escena: %s (OrbBoss.gd)"%[go_to])
				SceneChanger.change_scene(go_to)
			else:
				#print("ir a siguiente escena: resultados (OrbBoss.gd)")
				SceneChanger.change_scene("res://screens/MissionResults.tscn")
		
		else:
			Audio.play_sfx("boss_defeated_jingle")
			Audio.play_sfx("weapon_upgrade")
			Vars.player["hp_now"] = Vars.player["hp_max"]
			body.show_quick_notif(tr("HPRESTORED"))
			body.emit_signal("stats_changed")
		
			queue_free()
