extends Path2D

#especial thanks to PigDev for this way to make moving platforms

export(float,0.1,1) var playback_speed = 0.3

export var loop = false

func _ready():
	$AnimationPlayer2.play("rotate")
	$AnimationPlayer.playback_speed = playback_speed
	
	$Path2D.curve = curve
	
	if curve != null:
		if loop:
			$AnimationPlayer.play("LoopPathFollow")
		else:
			$AnimationPlayer.play("PingPongPathFollow")


#func _on_Saw_body_entered(body):
#	if body.is_in_group("player"):
#		body.hurt("circle_saw",$Saw.position)
