extends Node2D

func _ready():
	#ocultar botones
	ControlsOnscreen.show_buttons(false)
	Tr._load("res://content/custom_levels/Dracula'sRevengeTrailer/text.ini")
	Audio.stop_music()
	$AnimationPlayer.play("show")

func _process(_delta):
	if Input.is_action_just_pressed("ui_select"):
		SceneChanger.change_scene("res://screens/Credits.tscn")

func set_label_text(txt="text"):
	$Label/Tween.stop_all()
	$Label.modulate = Color(1,1,1,0)
	$Label.text = Tr._(txt)
	$Label/Tween.interpolate_property($Label,"modulate",$Label.modulate,Color(1,1,1,1),1)
	$Label/Tween.start()
func hide_label_text():
	$Label/Tween.stop_all()
	$Label/Tween.interpolate_property($Label,"modulate",$Label.modulate,Color(1,1,1,0),1)
	$Label/Tween.start()
