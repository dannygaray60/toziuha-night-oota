extends Node2D

var move = false

func _ready():
	Audio.play_sfx("electric_shock")
	$AnimSprites.play("create")
	$AnimationPlayer.play("spin")
	$TimerStartMove.start()
	yield($TimerStartMove,"timeout")
	$AnimSprites.play("idle")
	$TimerEnd.start()
	move = true
	
func _process(_delta):
	
	if move:
		$Sphaera1.position.x -= 0.2
		$Sphaera2.position.x += 0.2
	


func _on_TimerEnd_timeout():
	$AnimSprites.play("destroy")


func _on_AnimSprites_animation_finished(anim_name):
	match anim_name:
		"create":
			$AnimSprites.play("idle")
		"destroy":
			queue_free()


func _on_Sphaera_area_entered(area_body,area_name):
	if area_body.is_in_group("torch"):
		Audio.play_sfx("electric_zap")
		area_body.destroy()
	if area_body.is_in_group("enemies"):
		Audio.play_sfx("electric_zap")
		area_body.hurt(int(Vars.player["atk"]*4),get_node(area_name).global_position)
