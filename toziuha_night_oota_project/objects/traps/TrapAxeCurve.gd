extends Node2D

export var circle_animation = false
export(float, 0.3,1.5) var anim_speed = 0.8

func _ready():
	$AnimationPlayer.playback_speed = anim_speed
	if circle_animation:
		$AnimationPlayer.play("move_circle")
	else:
		$AnimationPlayer.play("move")


#func _on_Area_body_entered(body):
#	if body.is_in_group("player"):
#		body.hurt("curved_axe",$Area/CollisionPolygon2D.position)
