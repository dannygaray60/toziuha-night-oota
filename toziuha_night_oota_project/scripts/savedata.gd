extends Node

#clave para poder leer y escribir archivos de guardado
#estos serán diferentes entre la versión gratuita y la premium
#por lo que los guardados serán incompatibles entre las dos versiones
var savekey = "dfR&GRE&440858"

var err = OK

var dir = Directory.new()
var file = File.new()

#retornar true o false dependiendo si el tipo de archivo especificado existe
func has_savefile(type="quicksave"):
	return file.file_exists( "user://saves/%s.toziuhasave" % [get_namefile(type)] )

#obtener nombre del archivo de partida dependiendo el tipo
func get_namefile(type="quicksave"):
	match type:
		"quicksave":
			return "quick_"+Vars.level_dir_path.get_file().md5_text()
		"savegame":
			var namef = savekey+Vars.level_dir_path.get_file()
			return namef.md5_text()
		"mainsave":
			return "savedata"

func serialize_persistent_variables(type="quicksave"):
	var save_dict = {}
	if type in ["quicksave","savegame"]:
		#guardado rapido o desde estatua
		save_dict = {"player": Vars.player}
	elif type == "mainsave":
			#guardar datos generales, como dinero que se usará en la tienda de extras
			pass
	return save_dict

func save_savedata(type="quicksave"):
	
	if !dir.dir_exists("user://saves"):
		dir.make_dir("user://saves")
	
	var file_path = "user://saves/%s.toziuhasave" % [get_namefile(type)]

#	err = file.open_encrypted_with_pass(file_path,File.WRITE,savekey)
	err = file.open(file_path,File.WRITE)

	if err == OK:
		file.store_var(serialize_persistent_variables(type))
	else:
		return err

	file.close()
	return err

#cargar datos del juego
func load_savedata(type="quicksave"):
	
	var file_path = "user://saves/%s.toziuhasave" % [get_namefile(type)]
	
	#el archivo no existe...
	if !file.file_exists(file_path):
		return ERR_FILE_NOT_FOUND
		
#	err = file.open_encrypted_with_pass(file_path,File.WRITE,savekey)
	err = file.open(file_path,File.READ)
	var player_data = []
	
	if err == OK:
		if type in ["quicksave","savegame"]:
			player_data = file.get_var()
			#establecer variables persistentes a partir de los datos obtenidos
			Vars.player = player_data["player"]
		elif type == "mainsave":
			#restaurar variables de los datos generales
			pass

	file.close()
	return OK

func delete_savedata(type="quicksave"):
	var file_path = "user://saves/%s.toziuhasave" % [get_namefile(type)]
	if file.file_exists(file_path):
		dir.remove(file_path)
