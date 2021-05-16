extends RigidBody2D

var end_of_level = false

func _ready():
	$Area2DTile.monitoring = false
	Audio.play_sfx("boss_orb_generating")
	$AnimationPlayer.play("show")

func flash():
	Functions.get_main_level_scene().get_node("Hud").show_flash()
func play_heartbeat():
	Audio.play_sfx("boss_orb_heartbeat")
func play_orb_generated():
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
			print("ir a siguiente escena")
		
		else:
			Audio.play_sfx("boss_defeated_jingle")
			Audio.play_sfx("weapon_upgrade")
			Vars.player["hp_now"] = Vars.player["hp_max"]
			body.show_quick_notif(tr("HPRESTORED"))
			body.emit_signal("stats_changed")
		
			queue_free()
