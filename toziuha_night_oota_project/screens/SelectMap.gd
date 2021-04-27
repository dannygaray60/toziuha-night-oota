extends Control

var lvl_btn = preload("res://objects/ui/MainButton.tscn")
var lvl_btn_instance = null

var err

var scan_path = ""

var list_levels = {}

var dir = Directory.new()
var file = File.new()
var level_ini = ConfigFile.new()

export(String, "story_mode","custom_levels") var list_mode = "custom_levels"

func _ready():
	
	Audio.play_music("boss_theme")
		
	if !scan_levels():
		$PanelReturn/MarginContainer/BtnReturn.focus()
		$PanelBtns/Scroll/Margin/VBx.visible = false
		$PanelBtns/Scroll/Margin/VBxEmptyList.visible = true
		return

	$PanelBtns/Scroll/Margin/VBx.visible = true
	$PanelBtns/Scroll/Margin/VBxEmptyList.visible = false
	$PanelBtns/Scroll/Margin/VBx.get_children()[0].grab_focus()



func scan_levels():
	scan_path = "res://content/"+list_mode
	var level_dirs = get_dirs(scan_path)
	
	#filtrar las carpetas que sean de niveles
	#solo para los niveles externos
	if list_mode == "custom_levels":
		for d in level_dirs:
			#archivos dentro de la carpeta de la carpeta actual escaneada
			var files = get_files(scan_path+"/"+d)
			#si en la carpeta falta un data.ini
			#no será considerado un nivel y será eliminado de la lista
			if !files.has("data.ini"):
				level_dirs.erase(d)
			#el nivel es valido entonces agregamos datos
			else:
				level_ini = ConfigFile.new() #reiniciar para no tener datos restantes
				#el string de los .ini debe ir entre comillas de lo contrario manda error
				level_ini.load(scan_path+"/"+d+"/"+"data.ini")
				#instanciar botón
				lvl_btn_instance = lvl_btn.instance()
				#añadir datos al botón
				lvl_btn_instance.dir_name = d
				lvl_btn_instance.title = level_ini.get_value("info","title","No title...")
				lvl_btn_instance.description = level_ini.get_value("info","description","Description not available...")
				lvl_btn_instance.made_by = level_ini.get_value("info","made_by","Unknown")
				#añadir el nombre del archivo de escena que será la primera en cargar
				lvl_btn_instance.main_scene = level_ini.get_value("info","main_scene","")
				#si no hay un nombre de escena principal, el botón será desactivado
				if lvl_btn_instance.main_scene == "":
					lvl_btn_instance.disabled = true
				#si existe imagen del cover (cover.jpg)
				if ResourceLoader.exists(scan_path+"/%s/cover.jpg"%[d]):
					lvl_btn_instance.cover = load(scan_path+"/%s/cover.jpg"%[d])
				#conectar señal y si la conexion fue exitosa se añade el botón
				if lvl_btn_instance.connect("pressed",self,"_on_selected_level",[lvl_btn_instance.name]) == OK:
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
	
	var go_to = "%s/%s/%s.tscn"%[scan_path,get_focus_owner().dir_name,get_focus_owner().main_scene]
	#si existe el archivo 
	if file.file_exists(go_to):
		
		Audio.play_sfx("btn_accept")
		Vars.level_dir_path = "%s/%s" % [scan_path,get_focus_owner().dir_name]
		SceneChanger.change_scene(go_to)
		
		
		Vars.map_rooms = {} #reiniciar diccionario al elegir nuevo mapa a jugar
		Vars.map_object = null
		
		#si existe una escena del mapa
		if file.file_exists(Vars.level_dir_path+"/map.tscn"):
			Vars.map_object = load(Vars.level_dir_path+"/map.tscn")
		

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
