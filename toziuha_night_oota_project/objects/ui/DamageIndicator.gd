extends Node2D

var font_red = preload("res://fonts_tres/DamageIndicatorEnemy.tres")
var font_black = preload("res://fonts_tres/DamageIndicatorPlayer.tres")
var font_green = preload("res://fonts_tres/HealthIndicator.tres")
var font_blue = preload("res://fonts_tres/HealthIndicator_blue.tres")

func _ready():
	
	var end_pos = position
	end_pos.y -= 20
	
	$AnimationPlayer.play("show")
	$Tween.interpolate_property(self,"position",position,end_pos,1.5,
	Tween.TRANS_LINEAR,Tween.TRANS_LINEAR)
	$Tween.start()

func set_damage(val=00,color="black"):
	
	match color:
		"red":
			$Txt.add_font_override("font",font_red)
		"green":
			$Txt.add_font_override("font",font_green)
		"blue":
			$Txt.add_font_override("font",font_blue)
		"_":
			$Txt.add_font_override("font",font_black)
		
	$Txt.text = str(val)#.pad_zeros(2)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "show":
		queue_free()
