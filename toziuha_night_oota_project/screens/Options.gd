extends Control

var Conf = load("res://scripts/config.gd").new()

var selected_section = ""

#para remapeo
var remap_type = "keyboard"
var remap_action = "ui_select"
var remap_name_btn = "Btn"

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

	#ocultar opciones de acuerdo al dispositivo
	#si el dispositivo no tiene pantalla tactil, se ocultaran opciones relacionadas al touch
	if !OS.has_touchscreen_ui_hint():
		$Margin/HBx/VBx/Panel/Margin/VBx/BtnTouchscreen.visible = false
	#en dispositivos moviles se desactivan fullscreen, borderless
	#y opciones de teclado
	if OS.get_name() in ["Android", "iOS"]:
		$Margin/HBx/VBx/Panel/Margin/VBx/BtnControls.visible = false
		$Margin/HBx/PanelVideo/Margin/VBx/ShowKeyboardIcons.visible = false
		$Margin/HBx/PanelVideo/Margin/VBx/FullScr.visible = false
		$Margin/HBx/PanelVideo/Margin/VBx/Borderless.visible = false
	
	#si no hay al menos un gamepad conectado
	#se desactivan opciones sobre gamepad
	if Input.get_connected_joypads().size() == 0:
		$Margin/HBx/PanelVideo/Margin/VBx/BtnConfIcons.disabled = true
		$Margin/HBx/VBx/Panel/Margin/VBx/BtnGamepad.disabled = true
		$Margin/HBx/PanelVideo/Margin/VBx/ShowGamepadIcons/CheckBox.disabled = true
	
#ocultar paneles de las secciones
func hide_all_section_panels():
	$Margin/HBx/PanelVideo.visible = false
	$Margin/HBx/PanelAudio.visible = false
	$Margin/HBx/PanelControls.visible = false
	$Margin/HBx/PanelGamepad.visible = false
	$Margin/HBx/PanelControlsTouchScreen.visible = false
	$Margin/HBx/PanelLang.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and !$ControlRemap.visible and $ControlRemap/TimerRemap.get_time_left() == 0:
		
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
			$Margin/HBx/PanelVideo/Margin/VBx/BtnFilters.focus()
		"BtnControls":
			selected_section = opt
			$Margin/HBx/PanelControls.visible = true
			$Margin/HBx/PanelControls/Margin/VBx/BtnJump/Btn.focus()
		"BtnGamepad":
			selected_section = opt
			$Margin/HBx/PanelGamepad.visible = true
			$Margin/HBx/PanelGamepad/Margin/VBx/BtnJump/Btn.focus()
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
	#refrescar iconos en caso de ser necesario
	if section == "gamepad_icon" and key == "visible":
		for b in get_tree().get_nodes_in_group("btn_help_icon"):
			b.update_icon()

#obtener las diferentes configuraciones y asignarlas a los controles
func load_config_and_set_controls():
	#------- video
	#set_pressed para ponerle valores sin que haga ruido
	#checkbox de fullscreen
	$Margin/HBx/PanelVideo/Margin/VBx/FullScr/CheckBox.set_pressed(Conf.get_conf_value("video","fullscreen",false))
	#borderless
	$Margin/HBx/PanelVideo/Margin/VBx/Borderless/CheckBox.set_pressed(Conf.get_conf_value("video","borderless",false))
	#show icons gamepad
	match Conf.get_conf_value("video","icons_buttons","hide"):
		"keyboard":
			$Margin/HBx/PanelVideo/Margin/VBx/ShowKeyboardIcons/CheckBox.set_pressed(true)
		"gamepad":
			$Margin/HBx/PanelVideo/Margin/VBx/ShowGamepadIcons/CheckBox.set_pressed(true)
		"hide":
			$Margin/HBx/PanelVideo/Margin/VBx/HideBtnIcons/CheckBox.set_pressed(true)
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

func _input(event):
	
	if !$ControlRemap.visible:
		
		if $Margin/HBx/PanelGamepad.visible and Input.is_action_just_pressed("ui_focus_prev") and Input.is_action_pressed("ui_down"):
			Audio.play_sfx("btn_accept")
			SceneChanger.change_scene("res://screens/ApplyMappingString.tscn")
			#print("ir a pantalla de arreglo de gamepad (añadir mapping string)")
		
		return
	
	if event.is_pressed():
		
		if event is InputEventKey and event.as_text() == "Escape":
			hide_screen_remap()
			return
		
		if (remap_type == "gamepad" and (event is InputEventJoypadButton or event is InputEventJoypadMotion)) or (remap_type == "keyboard" and event is InputEventKey):
			$ControlRemap/TimerRemap.start()
			apply_remap(event)
		else:
			print(str(event))
			Audio.play_sfx("btn_incorrect")
	
	
#se ha seleccionado un boton para remapear una accion especifica
#type: gamepad o keyboard
#action: action del inputmap
#name_btn: nombre del botón presionado (para regresarle el focus después)
#timer usado para evitar señal duplicada
func remap_to(type,action,name_btn):
	if !$ControlRemap.visible and $ControlRemap/TimerRemap.get_time_left() != 0.5:
		if type == "keyboard":
			$ControlRemap/Panel/MarginContainer/Label.text = tr("REMAP_MSG_KEYBRD")%[name_btn]
		else:
			$ControlRemap/Panel/MarginContainer/Label.text = tr("REMAP_MSG_GAMEPAD")%[name_btn]
		$ControlRemap.visible = true
		remap_type = type
		remap_action = action
		remap_name_btn = name_btn
		$ControlRemap/Button.grab_focus() #se le da focus a un botón invisible
		

func apply_remap(event):
	
	if event is InputEventJoypadButton or event is InputEventKey:
		pass
	else:
		return
	
	#comprobar si el boton elegido ya ha sido remapeado
	var valid_input = true
	#los codigos del config de la seccion keyboard o gamepad
	var saved_codes = []
	#codigo del boton presionado del keyboard o gamepad
	var code = 0
	
	if remap_type == "keyboard":
		code = event.get_scancode_with_modifiers()	
	elif remap_type == "gamepad":
		code = event.button_index
	
	#obtener lista de los codigos del boton (en keyboard o gamepad)
	for k in Conf.conf.get_section_keys(remap_type):
		saved_codes.append(Conf.conf.get_value(remap_type,k,0))
	
	if code in saved_codes:
		valid_input = false
	
	if !valid_input:
		Audio.play_sfx("btn_incorrect")
		$Notif/NotificationInGame.show_notif("The button/key is in use, please choose another one.",3)
		return
	
	#recorrer los eventos de la accion
	for ev in InputMap.get_action_list(remap_action):
		#si el tipo de mapeo es de teclado y el evento es también de teclado
		#o el tipo de mapeo es gamepad al igual que el evento
		if (remap_type == "keyboard" and ev is InputEventKey) or (remap_type == "gamepad" and ev is InputEventJoypadButton):
			#se elimina el evento
			InputMap.action_erase_event(remap_action,ev)
			#y se añade el que se estableció
			InputMap.action_add_event(remap_action,event)
			#guardar conf
			if remap_type == "keyboard" and event is InputEventKey:
				Conf.set_conf_value("keyboard",remap_action,event.get_scancode_with_modifiers())
			elif remap_type == "gamepad" and event is InputEventJoypadButton:
				Conf.set_conf_value("gamepad",remap_action,event.button_index)
	
	hide_screen_remap()

func hide_screen_remap():
	#dar focus correspondiente
	match remap_type:
		"keyboard":
			get_node("Margin/HBx/PanelControls/Margin/VBx/"+remap_name_btn+"/Btn").grab_focus()
			get_node("Margin/HBx/PanelControls/Margin/VBx/"+remap_name_btn+"/Icon").update_icon()
		"gamepad":
			get_node("Margin/HBx/PanelGamepad/Margin/VBx/"+remap_name_btn+"/Btn").grab_focus()
			get_node("Margin/HBx/PanelGamepad/Margin/VBx/"+remap_name_btn+"/Icon").update_icon()
	
	
	for b in get_tree().get_nodes_in_group("btn_help_icon"):
		b.update_icon()

	$ControlRemap.visible = false	


func option_changed_icon_visibility(btn_pressed,opt):
	if btn_pressed:
		Conf.set_conf_value("video","icons_buttons",opt)
		for b in get_tree().get_nodes_in_group("btn_help_icon"):
			b.update_icon()


func _on_BtnConfIcons_pressed():
	SceneChanger.change_scene("res://screens/EditGamepadIcons.tscn")


func _on_BtnFilters_pressed():
	SceneChanger.change_scene("res://screens/SelectVideoFilter.tscn")
