extends Path2D

#especial thanks to PigDev for this way to make moving platforms

export(float,0.1,1) var playback_speed = 0.5

export var loop = false

func _ready():
	
	$AnimationPlayer.playback_speed = playback_speed
	
	$Path2D.curve = curve
	
	if curve != null:
		if loop:
			$AnimationPlayer.play("LoopPathFollow")
		else:
			$AnimationPlayer.play("PingPongPathFollow")
