extends Control

func _ready():
	$Panel0/Margin/VBx/BtnMenu.focus()


func _on_BtnMenu_pressed():
	SceneChanger.change_scene("res://screens/MainMenu.tscn")
