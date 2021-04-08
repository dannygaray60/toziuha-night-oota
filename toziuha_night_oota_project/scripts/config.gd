extends Node

#var f = File.new()
#var d = Directory.new()
var conf = ConfigFile.new()

#comprobar archivo de configuracion
func check_configfile(configfile="user://settings.cfg"):
	var err
	err = conf.load(configfile)
	if err == ERR_FILE_NOT_FOUND:
		#si no existe el archivo se crea uno
		print("config.gd: ERR_FILE_NOT_FOUND creating new configfile")
		err = conf.save(configfile)
		
	# Store a variable if and only if it hasn't been defined yet
	
	#-------- seccion de video
	check_conf_setting("video", "fullscreen", false)
	check_conf_setting("video", "borderless", false)
	
	#-------- seccion de audio
	check_conf_setting("audio", "sfx", 1.0)
	check_conf_setting("audio", "bgm", 1.0)
	check_conf_setting("audio", "voice", 1.0)
		
	#--------- configuracion de teclado
	#pausa - enter
	check_conf_setting("keyboard", "ui_select", 0)
	#salto - aceptar
	check_conf_setting("keyboard", "ui_accept", 0)
	#ataque - cancelar
	check_conf_setting("keyboard", "ui_cancel", 0)
	#sin usar
#	if not conf.has_section_key("keyboard", "ui_focus_next"):
#		conf.set_conf_value("keyboard", "ui_focus_next", 0)
	#backdash
	check_conf_setting("keyboard", "ui_focus_prev", 0)
	#arriba
	check_conf_setting("keyboard", "ui_up", 0)
	#abajo
	check_conf_setting("keyboard", "ui_down", 0)
	#izquierda
	check_conf_setting("keyboard", "ui_left", 0)
	#derecha
	check_conf_setting("keyboard", "ui_right", 0)
		
	#--------- configuracion de gamepad
	#pausa - enter
	check_conf_setting("gamepad", "ui_select", 0)
	#salto - aceptar
	check_conf_setting("gamepad", "ui_accept", 0)
	#ataque - cancelar
	check_conf_setting("gamepad", "ui_cancel", 0)
	#sin usar
#	if not conf.has_section_key("gamepad", "ui_focus_next"):
#		conf.set_conf_value("gamepad", "ui_focus_next", 0)
	#backdash
	check_conf_setting("gamepad", "ui_focus_prev", 0)
	#arriba
	check_conf_setting("gamepad", "ui_up", 0)
	#abajo
	check_conf_setting("gamepad", "ui_down", 0)
	#izquierda
	check_conf_setting("gamepad", "ui_left", 0)
	#derecha
	check_conf_setting("gamepad", "ui_right", 0)
		
	#configuracion de botones virtuales
	#opacidad de botones
	check_conf_setting("touchscreenbutton", "opacity", 0.71)
	#tamaño de cada botón
	check_conf_setting("touchscreenbutton", "size", 1)
	#mostrar controles
	if not conf.has_section_key("touchscreenbutton", "show_buttons"):
		if OS.get_name() == "Android":
			conf.set_value("touchscreenbutton", "show_buttons", true)
		else:
			conf.set_value("touchscreenbutton", "show_buttons", false)
	#pausa - enter
	check_conf_setting("touchscreenbutton", "ui_select", Vector2( 649.494, 32.4725 ))
	#salto - aceptar
	check_conf_setting("touchscreenbutton", "ui_accept", Vector2(631.453, 279.882))
	#ataque - cancelar
	check_conf_setting("touchscreenbutton", "ui_cancel", Vector2(552.07, 330.395))
	#backdash
	check_conf_setting("touchscreenbutton", "ui_focus_prev", Vector2(629.391, 180.403))
	#arriba abajo izquierda derecha (el centro de estos botones en grupo)
	check_conf_setting("touchscreenbutton", "dpad", Vector2(96.3932, 280.913))

	#--------- idioma
	var langlocale = TranslationServer.get_locale()
	if not conf.has_section_key("other", "lang"):
		if langlocale=="es" or langlocale.begins_with("es_") or langlocale.begins_with("es-"):
			langlocale="es"
		else:
			langlocale="en"
	check_conf_setting("other", "lang", langlocale)

	#guardar cambios predeterminados en el config nuevo
	err = conf.save(configfile)
	
	#problemas guardando el archivo config
	if err != OK:
		print("config.gd: error saving configfile: %d"%[err])
		return


#cargar un valor de configuracion
func get_conf_value(section,key,default_value,configfile="user://settings.cfg"):
	#cargar el archivo
	var err = conf.load(configfile)
	if err != OK:
		print("config.gd: error loading configfile: %d"%[err])
		return 
	return conf.get_value(section,key,default_value)

#guardar un valor de configuracion
func set_conf_value(section,key,value,configfile="user://settings.cfg"):
	#cargar el archivo
	var err = conf.load(configfile)
	if err != OK:
		print("config.gd: error loading configfile: %d"%[err])
		return
	#las configuraciones de audio necesitan convertirse antes de guardarlas
	if section == "audio" and key in ["sfx","bgm","voice"]:
		value = value / 100
	conf.set_value(section,key,value)
	err = conf.save(configfile)
	if err != OK:
		print("config.gd: error saving configfile: %d"%[err])
		return
	#algunas opciones requieren aplicarlas en tiempo real
	apply_conf_setting(section,key,value)
	return err

#aplicar configuraciones
func apply_conf_setting(section,key,value):
	match section:
		"video":
			match key:
				"fullscreen":
					OS.window_fullscreen = value
				"borderless":
					OS.window_borderless = value
		"audio":
			match key:
				"sfx":
					AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"),linear2db(value))
				"bgm":
					AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear2db(value))
				"voice":
					AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"),linear2db(value))
		"other":
			match key:
				"lang":
					TranslationServer.set_locale(value)

#comprobar configuracion
func check_conf_setting(section,key,value):
	if not conf.has_section_key(section, key):
		conf.set_value(section, key, value)
	apply_conf_setting(section,key,conf.get_value(section,key,value))
