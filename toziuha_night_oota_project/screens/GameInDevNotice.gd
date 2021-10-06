extends Control

var Conf = load("res://scripts/config.gd").new()

func _enter_tree():
	if Input.get_connected_joypads().size() > 0: #si hay un gamepad conectado
		Conf.set_conf_value("video", "icons_buttons", "gamepad")
	else:
		Conf.set_conf_value("video", "icons_buttons", "keyboard")

func _ready():
	#ocultar mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	$HBoxContainer3/BtnAccept.focus()

func _on_BtnKofi_pressed():
	if OS.shell_open("https://dannygaray60.itch.io/toziuha-night-order-of-the-alchemists") == OK:
		$Notif/NotificationInGame.show_notif("Opening external link...",3)
		

func _on_BtnEng_focus_entered():
	Conf.set_conf_value("other","lang","en")
func _on_BtnEsp_focus_entered():
	Conf.set_conf_value("other","lang","es")
func _on_BtnPT_focus_entered():
	Conf.set_conf_value("other","lang","pt")


func _on_BtnAccept_pressed():
	SceneChanger.change_scene("res://screens/SplashScreen.tscn")
