extends CanvasLayer

var Conf = load("res://scripts/config.gd").new()

var edited_button = "none"

func _ready():
	
	$Dpad.position = Conf.get_conf_value("touchscreenbutton","dpad",$Dpad.position)
	
	$VBoxContainer/Transparency/SliderTransparency.value = Conf.get_conf_value("touchscreenbutton","opacity",1)
	$VBoxContainer/Size/SliderSize.value = Conf.get_conf_value("touchscreenbutton","size",1)
	
	for b in $Btn.get_children():
		b.position = Conf.get_conf_value("touchscreenbutton",b.name,Vector2(0,0))
		b.scale = Vector2($VBoxContainer/Size/SliderSize.value,$VBoxContainer/Size/SliderSize.value)
		b.get_node("Btn").connect("released",self,"button_pressed",["none"])
		b.get_node("Btn").connect("pressed",self,"button_pressed",[b.name])
		
	$Dpad.scale = Vector2($VBoxContainer/Size/SliderSize.value,$VBoxContainer/Size/SliderSize.value)
	for dpad in $Dpad.get_children():
		dpad.get_node("Btn").connect("released",self,"button_pressed",["none"])
		dpad.get_node("Btn").connect("pressed",self,"button_pressed",["dpad"])

	$Btn.modulate.a = $VBoxContainer/Transparency/SliderTransparency.value
	$Dpad.modulate.a = $VBoxContainer/Transparency/SliderTransparency.value

func _process(_delta):
	if edited_button == "dpad":
		get_node("Dpad").position = $Dpad.get_global_mouse_position()
	elif edited_button != "none":
		get_node("Btn/"+edited_button).position = $Btn.get_global_mouse_position()

func button_pressed(namebtn):
	edited_button = namebtn
	
#acción a realizar
func selected_action(opt):
	match opt:
		"save":
			for b in $Btn.get_children():
				Conf.set_conf_value("touchscreenbutton",b.name,b.position)
			Conf.set_conf_value("touchscreenbutton","dpad",$Dpad.position)
			Conf.set_conf_value("touchscreenbutton","opacity",$VBoxContainer/Transparency/SliderTransparency.value)
			Conf.set_conf_value("touchscreenbutton","size",$VBoxContainer/Size/SliderSize.value)
			SceneChanger.change_scene("res://screens/Options.tscn")
			ControlsOnscreen._ready()
		"cancel":
			SceneChanger.change_scene("res://screens/Options.tscn")
		"default":
			$VBoxContainer/Transparency/SliderTransparency.value = 0.6
			$VBoxContainer/Size/SliderSize.value = 1
			#posiciones por defecto
			$Btn/ui_select.position =Vector2( 649.494, 32.4725 )
			$Btn/ui_accept.position = Vector2(631.453, 279.882)
			$Btn/ui_cancel.position = Vector2(552.07, 330.395)
			$Btn/ui_focus_prev.position = Vector2(629.391, 180.403)
			$Dpad.position = Vector2(96.3932, 280.913)


func _on_SliderOpacity_value_changed(value):
	$Btn.modulate.a = value
	$Dpad.modulate.a = value


func _on_SliderSize_value_changed(value):
	for b in $Btn.get_children():
		b.scale = Vector2(value,value)
	$Dpad.scale = Vector2(value,value)
