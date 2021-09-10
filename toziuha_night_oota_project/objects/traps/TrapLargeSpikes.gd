extends Node2D

#tiempo que permanece inactivo antes de moverse de nuevo
export var time_start = 2

func _ready():
	$TimerStartMove.wait_time = time_start

func _on_AnimationPlayer_animation_finished(anim_name):

	match anim_name:
		"blink":
			$AnimationPlayer.play("move")
		"move":
			$TimerStartMove.start()


func _on_TimerStartMove_timeout():
	$AnimationPlayer.play("blink")


func _on_VisibilityEnabler2D_screen_entered():
	$AnimationPlayer.play("blink")


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "move" and $VisibilityEnabler2D.is_on_screen():
		Audio.play_sfx("spike_slash")
