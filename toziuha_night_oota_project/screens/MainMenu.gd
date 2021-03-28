extends Control

func _ready():
	Audio.play_music("rondo_of_darkness")

func _on_BtnStart_pressed():
	SceneChanger.change_scene("res://test/test_change_rooms/Main.tscn")


func _on_BtnStart2_pressed():
	SceneChanger.change_scene("res://test/LevelTest1.tscn")
