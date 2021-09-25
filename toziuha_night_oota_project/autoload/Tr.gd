extends Node

var dialog = ConfigFile.new()
var err = 0
	
func _load(filepath):
	err = dialog.load(filepath)
	if err != OK:
		print("error loading ini: "+str(err))

#retornar texto traducido
#recibiendo un id del texto que se quiere la traducción
func _(id):
	
	var lang = TranslationServer.get_locale()
	
	var output = ""
	
	if err != OK:
		return
	
	#si existe un texto traducido del dialogo requerido
	if dialog.has_section_key(id, lang):
		output = dialog.get_value(id,lang,"NOTEXT")
	#en caso contrario mostrar uno en inglés
	#si el dialogo no existe se muestra NOTEXT
	else:
		output = dialog.get_value(id,"en","NOTEXT")

	return output
