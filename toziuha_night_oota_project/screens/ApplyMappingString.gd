extends Control

var Conf = load("res://scripts/config.gd").new()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$TextEdit.text = Conf.get_conf_value("other","gamepad_mapping_string","")
	$TextEdit.grab_focus()

func _process(_delta):
	
	if Input.is_action_pressed("ui_accept"):
		$Label4.text = "-> %s <-" % [tr("OPT_BTN_JUMPANDACCEPT")]
	elif Input.is_action_pressed("ui_cancel"):
		$Label4.text = "-> %s <-" % [tr("OPT_BTN_ATTACKANDCANCEL")]
	elif Input.is_action_pressed("ui_select"):
		$Label4.text = "-> %s <-" % [tr("OPT_BTN_START")]
	elif Input.is_action_pressed("ui_focus_prev"):
		$Label4.text = "-> %s <-" % [tr("BACKWARD")]
	elif Input.is_action_pressed("ui_focus_next"):
		$Label4.text = "-> %s <-" % [tr("SUBWEAPON")]
	elif Input.is_action_pressed("ui_up"):
		$Label4.text = "-> %s <-" % [tr("UP")]
	elif Input.is_action_pressed("ui_down"):
		$Label4.text = "-> %s <-" % [tr("DOWN")]
	elif Input.is_action_pressed("ui_left"):
		$Label4.text = "-> %s <-" % [tr("LEFT")]
	elif Input.is_action_pressed("ui_right"):
		$Label4.text = "-> %s <-" % [tr("RIGHT")]
		

func _on_BtnApply_pressed():
	Audio.play_sfx("btn_accept")
	Conf.set_conf_value("other","gamepad_mapping_string",$TextEdit.text)
	Input.add_joy_mapping(Conf.get_conf_value("other","gamepad_mapping_string",$TextEdit.text), true)


func _on_BtnReturn_pressed():
	Audio.play_sfx("btn_cancel")
	SceneChanger.change_scene("res://screens/Options.tscn")


func _on_ApplyMappingString_tree_exiting():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
