extends Control

func _ready():
	$AnimationPlayer.play("show_danny")

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		if $AnimationPlayer.current_animation == "show_danny":
			$AnimationPlayer.play("show_godot")
		elif $AnimationPlayer.current_animation == "show_godot":
			$AnimationPlayer.stop()
			end_show()
		

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"show_danny":
			$AnimationPlayer.play("show_godot")
		"show_godot":
			end_show()

func end_show():
	$Sprite.frame = 63
	SceneChanger.change_scene("res://screens/StartScr.tscn")
