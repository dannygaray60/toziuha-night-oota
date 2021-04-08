extends Control

var Conf = load("res://scripts/config.gd").new()

var selected_section = ""

func _ready():
	
	Audio.play_music("boss_theme")
	
	hide_all_section_panels()
	
	load_config_and_set_controls()
	
	#con play_sound(dentro del script del boton) evitamos que suene el botón al recibir el primer focus
	$Margin/HBx/VBx/Panel0/Margin/VBx/BtnMenu.focus()

	#ocultar iconos del panel audio
	$Margin/HBx/PanelAudio/Margin/VBx/Sfx/Icon.modulate.a = 0
	$Margin/HBx/PanelAudio/Margin/VBx/Bgm/Icon.modulate.a = 0
	$Margin/HBx/PanelAudio/Margin/VBx/Voice/Icon.modulate.a = 0

	
	
#ocultar paneles de las secciones
func hide_all_section_panels():
	$Margin/HBx/PanelVideo.visible = false
	$Margin/HBx/PanelAudio.visible = false
	$Margin/HBx/PanelControls.visible = false
	$Margin/HBx/PanelGamepad.visible = false
	$Margin/HBx/PanelControlsTouchScreen.visible = false
	$Margin/HBx/PanelLang.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Audio.play_sfx("btn_cancel")

		if get_focus_owner().name == "BtnMenu":
			SceneChanger.change_scene("res://screens/MainMenu.tscn")
			return
			
		if selected_section != "":
			get_node("Margin/HBx/VBx/Panel/Margin/VBx/%s"%[selected_section]).focus()
			get_node("Margin/HBx/VBx/Panel/Margin/VBx/%s"%[selected_section]).pressed = false
			hide_all_section_panels()
			selected_section = ""
		else:
			$Margin/HBx/VBx/Panel0/Margin/VBx/BtnMenu.focus()

#se seleccionó una opcion principal (panel izquierda)
func select_section(opt):
	hide_all_section_panels()
	#quitarle pressed a todos los botones
	for b in $Margin/HBx/VBx/Panel/Margin/VBx.get_children():
		if b.name != get_focus_owner().name:
			b.get_node("Icon").visible = false
	match opt:
		"main_menu":
			SceneChanger.change_scene("res://screens/MainMenu.tscn")
		"BtnAudio":
			selected_section = opt
			$Margin/HBx/PanelAudio.visible = true
			$Margin/HBx/PanelAudio/Margin/VBx/Sfx/Slider.focus()
		"BtnVideo":
			selected_section = opt
			$Margin/HBx/PanelVideo.visible = true
			$Margin/HBx/PanelVideo/Margin/VBx/FullScr/CheckBox.focus()
		"BtnControls":
			selected_section = opt
			$Margin/HBx/PanelControls.visible = true
			$Margin/HBx/PanelControls/Margin/VBx/BtnJump.focus()
		"BtnGamepad":
			selected_section = opt
			$Margin/HBx/PanelGamepad.visible = true
			$Margin/HBx/PanelGamepad/Margin/VBx/BtnJump.focus()
		"BtnTouchscreen":
			selected_section = opt
			$Margin/HBx/PanelControlsTouchScreen.visible = true
			$Margin/HBx/PanelControlsTouchScreen/Margin/VBx/Show/CheckBox.focus()
		"BtnLang":
			selected_section = opt
			$Margin/HBx/PanelLang.visible = true
			$Margin/HBx/PanelLang/Margin/VBx/English/CheckBox.focus()

#mostrar iconos en el panel de audio	
func _on_ItemPanel_focus_entered(extra_arg_0,panel="Audio"):
	get_node("Margin/HBx/Panel%s/Margin/VBx/%s/Icon"%[panel,extra_arg_0]).modulate.a = 1
func _on_ItemPanel_focus_exited(extra_arg_0,panel="Audio"):
	get_node("Margin/HBx/Panel%s/Margin/VBx/%s/Icon"%[panel,extra_arg_0]).modulate.a = 0

#una opción se cambió desde pantalla, esto se aplicará al archivo config
func option_changed(value,section,key):
	Conf.set_conf_value(section,key,value)

#obtener las diferentes configuraciones y asignarlas a los controles
func load_config_and_set_controls():
	#------- video
	#set_pressed para ponerle valores sin que haga ruido
	#checkbox de fullscreen
	$Margin/HBx/PanelVideo/Margin/VBx/FullScr/CheckBox.set_pressed(Conf.get_conf_value("video","fullscreen",false))
	#borderless
	$Margin/HBx/PanelVideo/Margin/VBx/Borderless/CheckBox.set_pressed(Conf.get_conf_value("video","borderless",false))
	#-----audio
	$Margin/HBx/PanelAudio/Margin/VBx/Sfx/Slider.set_value(Conf.get_conf_value("audio","sfx",1) * 100)
	$Margin/HBx/PanelAudio/Margin/VBx/Bgm/Slider.set_value(Conf.get_conf_value("audio","bgm",1) * 100)
	$Margin/HBx/PanelAudio/Margin/VBx/Voice/Slider.set_value(Conf.get_conf_value("audio","voice",1) * 100)
	#touchscreen button mostrar
	$Margin/HBx/PanelControlsTouchScreen/Margin/VBx/Show/CheckBox.set_pressed(Conf.get_conf_value("touchscreenbutton", "show_buttons",false))
	#-------idioma
	match Conf.get_conf_value("other", "lang", "en"):
		"es":
			$Margin/HBx/PanelLang/Margin/VBx/Espanol/CheckBox.set_pressed(true)
		_:
			$Margin/HBx/PanelLang/Margin/VBx/English/CheckBox.set_pressed(true)



func _on_BtnConfigure_pressed():
	SceneChanger.change_scene("res://screens/EditTouchscreenButtons.tscn")
