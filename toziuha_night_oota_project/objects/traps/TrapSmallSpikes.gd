extends Node2D

export var static_spike = false
export (float,0.2,3) var time_start = 1

func _ready():
	
	if static_spike:
		$Area2D/Sprite.frame = 7
		$Area2D/CollisionShape2D.disabled = false
	else:
		$Area2D/Sprite.frame = 0
	
	$Timer.wait_time = time_start
	

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.hurt("small_spikes",$Area2D.position)


func play_sound():
	if $VisibilityEnabler2D.is_on_screen():
		Audio.play_sfx("spike_slash2")


func _on_Timer_timeout():
	if !static_spike:
		$AnimationPlayer.play("show")


func _on_VisibilityEnabler2D_screen_entered():
	$Timer.start()


func _on_AnimationPlayer_animation_finished(_anim_name):
	$Timer.start()
