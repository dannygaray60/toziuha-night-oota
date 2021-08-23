extends Control

var Conf = load("res://scripts/config.gd").new()

func _ready():
	#ocultar mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	$HBoxContainer2/BtnEng.focus()

func _on_BtnKofi_pressed():
	if OS.shell_open("https://ko-fi.com/dannygaray60") == OK:
		$Notif/NotificationInGame.show_notif("Opening external link...",3)
		


func _on_BtnContinue_pressed():
	SceneChanger.change_scene("res://screens/SplashScreen.tscn")


func _on_BtnEng_focus_entered():
	Conf.set_conf_value("other","lang","en")


func _on_BtnEsp_focus_entered():
	Conf.set_conf_value("other","lang","es")
