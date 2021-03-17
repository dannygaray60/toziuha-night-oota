extends Node2D

func _ready():
	
	var end_pos = position
	end_pos.y -= 20
	
	$AnimationPlayer.play("show")
	$Tween.interpolate_property(self,"position",position,end_pos,1.5,
	Tween.TRANS_LINEAR,Tween.TRANS_LINEAR)
	$Tween.start()

func set_damage(val=00):
	$Txt.text = str(val).pad_zeros(2)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "show":
		queue_free()
