extends Control

func _ready():
	
	_on_ScrollContainer_scrolled(0)
	
	if OS.get_name() in ["Android"]:
		$HBxHelp.visible = false
		$HBxHelp2.visible = true
	else:
		$HBxHelp.visible = true
		$HBxHelp2.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Audio.play_sfx("btn_cancel")
		SceneChanger.change_scene("res://screens/MainMenu.tscn")

func _on_BtnMenu_pressed():
	pass # Replace with function body.


func _on_ScrollContainer_scrolled(current_index):
	$Title.text = $ScrollContainer/CenterContainer/MarginContainer/HBoxContainer.get_children()[current_index].name
