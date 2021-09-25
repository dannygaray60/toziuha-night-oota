extends Control

var lvl_btn = preload("res://objects/ui/MainButton.tscn")
var lvl_btn_instance = null

var has_quicksave = false
var has_savegame = false

var err

var scan_path = ""

var list_levels = {}

var go_to = ""

var dir = Directory.new()
var file = File.new()
var level_ini = ConfigFile.new()

export(String, "story_mode","custom_levels") var list_mode = "custom_levels"

func _ready():
	
	#boton especial para emitir pressed en el botón seleccionado
	#solo visible en android donde puede ser necesario
	if OS.get_name() != "Android":
		$BtnPressSelected.visible = false
	$BtnPressSelected.get_node("Icon").visible = true
	
	Audio.play_music("boss_theme")
		
	if !scan_levels():
		$PanelReturn/MarginContainer/BtnReturn.focus()
		$PanelBtns/Scroll/Margin/VBx.visible = false
		$PanelBtns/Scroll/Margin/VBxEmptyList.visible = true
		return

	$PanelBtns/Scroll/Margin/VBx.visible = true
	$PanelBtns/Scroll/Margin/VBxEmptyList.visible = false
	
	
	#si la lista de niveles no está vacia
	if !$PanelBtns/Scroll/Margin/VBx.get_children().empty():
		$PanelBtns/Scroll/Margin/VBx.get_children()[0].grab_focus()
	else:
		$PanelBtns/Scroll/Margin/VBxEmptyList.visible = true
		$PanelBtns/Scroll/Margin/VBxEmptyList/BtnDownloadLvls.focus()


func scan_levels():
	scan_path = "res://content/"+list_mode
	
	#lista de carpetas (sus nombres)
	var level_dirs = get_dirs(scan_path)
	
	#guardará: array de items, cada item = [numero_orden,nombrecarpeta]
	#la lista ya estará filtrada de las carpetas que si sean niveles
	#(que cumpla requisitos de archivos necesarios)
	var level_dirs_db = []
	
	
	for d in level_dirs:
		var files = get_files(scan_path+"/"+d)
		#si en la carpeta falta un data.ini
		#no será considerado un nivel y será eliminado de la lista
		if files.has("data.ini"):
			level_ini = ConfigFile.new() #reiniciar para no tener datos restantes
			#el string de los .ini debe ir entre comillas de lo contrario manda error
			level_ini.load(scan_path+"/"+d+"/"+"data.ini")
			level_dirs_db.append([
				level_ini.get_value("info","order",999999),
				d
			])
	
	#reordenar elementos usando un int como numero de orden
	#con ordenes repetidos se usara a-z como orden
	level_dirs_db.sort_custom(Functions.MyCustomSorter, "sort_ascending")

	#solo para los niveles externos
	if list_mode == "custom_levels":
		#var d = [int (order), nombre carpeta]
		for d in level_dirs_db:
			#archivos dentro de la carpeta de la carpeta actual escaneada
			var files = get_files(scan_path+"/"+d[1])

			level_ini = ConfigFile.new() #reiniciar para no tener datos restantes
			#el string de los .ini debe ir entre comillas de lo contrario manda error
			level_ini.load(scan_path+"/"+d[1]+"/"+"data.ini")

			level_ini = ConfigFile.new() #reiniciar para no tener datos restantes
			#el string de los .ini debe ir entre comillas de lo contrario manda error
			level_ini.load(scan_path+"/"+d[1]+"/"+"data.ini")
			#instanciar botón
			lvl_btn_instance = lvl_btn.instance()
			#añadir datos al botón
			lvl_btn_instance.dir_name = d[1]
			lvl_btn_instance.title = level_ini.get_value("info","title","No title...")
			lvl_btn_instance.description = level_ini.get_value("info","description","Description not available...")
			lvl_btn_instance.made_by = level_ini.get_value("info","made_by","Unknown")
			#añadir el nombre del archivo de escena que será la primera en cargar
			lvl_btn_instance.main_scene = level_ini.get_value("info","main_scene","")
			#si no hay un nombre de escena principal, el botón será desactivado
			if lvl_btn_instance.main_scene == "":
				lvl_btn_instance.disabled = true
			#si existe imagen del cover (cover.jpg)
			if ResourceLoader.exists(scan_path+"/%s/cover.jpg"%[d[1]]):
				lvl_btn_instance.cover = load(scan_path+"/%s/cover.jpg"%[d[1]])
			#conectar señal y si la conexion fue exitosa se añade el botón
			if lvl_btn_instance.connect("pressed",self,"_on_selected_level",[lvl_btn_instance.name]) == OK:
				#señal focused
				lvl_btn_instance.connect("focus_entered",self,"_on_BtnLevelFocusChange")
				lvl_btn_instance.connect("focus_exited",self,"_on_BtnLevelFocusChange")
				#añadir el botón a la pantalla
				$PanelBtns/Scroll/Margin/VBx.add_child(lvl_btn_instance)
			#limpiar la instancia
			lvl_btn_instance = null
	
	#si no hay niveles válidos, terminamos escaneado y retornamos false
	if level_dirs.empty():
		err="EMPTY"
		return false
	


	
	return true

func _on_selected_level(_press):
	Vars.level_dir_path = "%s/%s" % [scan_path,get_focus_owner().dir_name]
	Vars.level_main_scene = get_focus_owner().main_scene
	Vars.map_rooms = {} #reiniciar diccionario al elegir nuevo mapa a jugar
	Vars.map_object = null
	
	go_to = "%s/%s/%s.tscn"%[scan_path,get_focus_owner().dir_name,get_focus_owner().main_scene]
	#si existe el archivo 
	if file.file_exists(go_to):
		Audio.play_sfx("btn_accept")
		has_quicksave = Savedata.has_savefile("quicksave")
		has_savegame = Savedata.has_savefile("savegame")
		#deshabilitar botón dependiendo si no hay un archivo relacionado
		if !has_quicksave:
			$ControlContinue/Panel/Margin/VBx/VBx/BtnQuickLoad.disabled = true
		if !has_savegame:
			$ControlContinue/Panel/Margin/VBx/VBx/BtnSavePoint.disabled = true
		
		#y darle focus al botón de mayor interés
		if has_quicksave:
			$ControlContinue/Panel/Margin/VBx/VBx/BtnQuickLoad.focus()
		elif has_savegame:
			$ControlContinue/Panel/Margin/VBx/VBx/BtnSavePoint.focus()
		#si no hay ninguno de los archivos de guardado proceder a cargar escenario desde el inicio
		else:
			load_level("newgame")
			return

		$ControlContinue.visible = true

func load_level(mode="newgame"):
	
	#si existe una escena del mapa
	if file.file_exists(Vars.level_dir_path+"/map.tscn"):
		Vars.map_object = load(Vars.level_dir_path+"/map.tscn")
		
	if mode != "cancel":
		$ControlContinue/Panel/Margin/VBx/Label.text = tr("LOADING")+"..."
		#ocultar botones
		$ControlContinue/Panel/Margin/VBx/VBx.visible = false
	
	match mode:
		"newgame":
			Audio.stop_music()
			Vars.set_vars()
			err = OK
			#eliminar quicksave
			if has_quicksave:
				Savedata.delete_savedata("quicksave")
			#y la partida anterior
#			if has_savegame:
#				Savedata.delete_savedata("savegame")
		"quickload":
			Audio.stop_music()
			Vars.set_vars()
			err = Savedata.load_savedata("quicksave")
			#una vez cargado se elimina el archivo de cargado rapido
			if err == OK:
				Savedata.delete_savedata("quicksave")
		"savestatue":
			Audio.stop_music()
			Vars.set_vars()
			err = Savedata.load_savedata("savegame")
			Vars.loaded_from_statue_save = true
			#una vez cargado se elimina el archivo de cargado rapido (en caso de existir uno)
			if err == OK:
				Savedata.delete_savedata("quicksave")	
		"cancel":
			Audio.play_sfx("btn_cancel")
			$ControlContinue.visible = false
			$PanelReturn/MarginContainer/BtnReturn.focus()
			return
	
	if err == OK:
		#establecer nueva ruta hacia donde ir al cargar
		if mode in ["quickload","savestatue"]:
			go_to = "%s/%s.tscn"%[Vars.level_dir_path,Vars.player["current_room"]]
		#cambiar escenario
		SceneChanger.change_scene(go_to)

func _on_BtnReturn_pressed():
	SceneChanger.change_scene("res://screens/MainMenu.tscn")

func get_dirs(path):
	var dirs = []
	dir.open(path)
	dir.list_dir_begin(true)
	var d = dir.get_next()
	while d != "":
		if dir.current_is_dir():
			dirs+= [d]
		d = dir.get_next()
	#retornara un string con los nombres de las carpetas
	return dirs
	

func get_files(path):
	var files = []
	dir.open(path)
	dir.list_dir_begin(true)
	var f = dir.get_next()
	while f !="":
		files+= [f]
		f = dir.get_next()
	#retornara un string con el nombre y extension del archivo
	return files

func _on_BtnLevelFocusChange():
	if OS.get_name() != "Android":
		return
	if get_focus_owner() != null and get_focus_owner().is_in_group("level_btn"):
		$BtnPressSelected.visible = true
	else:
		$BtnPressSelected.visible = false

func _on_BtnPressSelected_pressed():
	get_focus_owner().emit_signal("pressed")
