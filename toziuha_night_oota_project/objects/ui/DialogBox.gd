extends CanvasLayer

#emitido cuando el script ha terminado
# warning-ignore:unused_signal
signal script_started
# warning-ignore:unused_signal
signal script_ended
# warning-ignore:unused_signal
signal dialogbox_opened
# warning-ignore:unused_signal
signal dialogbox_closed

var active = false

#------------- variables modificables desde afuera --------------------
var settings = {
	"text_velocity": 0.02,
}
# "n":"nombre" - forma para abreviar nombres de personajes en el script
var chars = {
	"none" : "", #mostrar titulo vacío
	"x" : "Xandria",
	"r" : "Rachel",
}
#guardar texturas de imagenes, usando un nombre de referencia con el objeto textura
var img_textures = {
	"xandria_normal" : load("res://assets/img/portraits/xandria_normal.png"),
	"rachel_normal" : load("res://assets/img/portraits/rachel_normal.png"),
}
#guardar streams de e
var snd_streams = {}
# lineas del script ejemplo
"""
['say','who','what']  -----(who es chars[who])-----
['sprite','name_img','c1'] ---------(name_img es el nombre asociado en img_textures (dejar null para eliminar), c1 es primera posicion o c2)
['hide_sprite','c1'] ------ocultar sprite en la posicion deseada
['wait_time',wait_time] ---------tiempo de espera en segundos para avanzar a la siguiente linea
['scene_bg','name_img']
['play_bgm',name_stream]
['stop_bgm',name_stream]
['focus','char1'] --------focus en el char correspondiente
['focus_all'] --------focus en todos los char
"""
var lines = [
	['say','none','Presiona "aceptar" para continuar el mensaje.'],
	['focus','c2'],
	['sprite','xandria_normal','c2'],
	['say','x','Este es un mensaje de ejemplo...'],
	['focus','c1'],
	['sprite','rachel_normal','c1'],
	['say','r','Y este es otro mensaje. Luego se ocultará los sprites.'],
	['hide_sprite','c1'],
	['hide_sprite','c2'],
	['say','none','Ocultando panel y finalizando...'],
]
#///------- variables modificables desde afuera --------------------

#la linea en la que se encuentra el jugador (de la variable lines)
var current_line = 0
var total_lines = 0 #tamaño de lines-1

var lvl_base = null

func _ready():
	
	set_process(false)
	$Control.visible = false
	$Control/BtnContinueIcon.visible = false
	$TimerTextVel.wait_time = settings["text_velocity"]
	clear_screen()

#comenzar el script del dialogo
func begin():
	set_process(true)
	current_line = 0
	total_lines = lines.size()-1 #el index
	emit_signal("script_started")
	#pausar
	lvl_base = Functions.get_main_level_scene()
	if lvl_base != null:
		lvl_base.get_node("Hud").can_pause = false
	get_tree().paused = true
	#mostrar escenario
	next_line()

#terminar script VN
func end_now():
	current_line = total_lines + 1 #la nueva actual linea esta fuera del index, por lo que ya no hay mas lineas por mostar
	next_line()
	
#limpiar pantalla de elementos
func clear_screen():
	$Control/BtnContinueIcon.visible = false
	$Control/c1.texture = null
	$Control/c2.texture = null
	set_title()
	$Control/Margin/Panel/Margin/VBx/LblMsg.text = ""

#establecer titulo del dialogo, puede ser nombre del personaje hablando
func set_title(title=""):
	if title == "":
		$Control/Margin/Panel/Margin/VBx/LblTitle.visible = false
		$Control/Margin/Panel/Margin/VBx/LblTitle.text = ""
	else:
		$Control/Margin/Panel/Margin/VBx/LblTitle.visible = true
		$Control/Margin/Panel/Margin/VBx/LblTitle.text = "« %s »" % [title] 	

#siguiente linea en el script de dialogo
func next_line():

	#si ln sobrepasa el total, finalizamos
	if current_line > total_lines or !active:
		clear_screen()
		#$BackgroundMusic.stop() #detener cancion de fondo si la hay
		emit_signal("script_ended")
		return
		
	$Control/BtnContinueIcon.visible = false
		
	var ln = lines[current_line]

	match ln[0]:

		"say":
			set_title(chars[ln[1]])
			#quitamos indicador de texto siguiente
			$Control/BtnContinueIcon.visible = false
			#mensaje...
			$Control/Margin/Panel/Margin/VBx/LblMsg.text = "" #limpiar
			for c in ln[2]:
				$TimerTextVel.start()
				#si el ctc esta visible cortamos escritura del texto
				if $Control/BtnContinueIcon.visible:
					$Control/Margin/Panel/Margin/VBx/LblMsg.text = ""
					$Control/Margin/Panel/Margin/VBx/LblMsg.text = ln[2]
					break
				if c!=" " and $Control.modulate.a == 1 and $Control.visible:
					Audio.play_sfx("text_bip")
				$Control/Margin/Panel/Margin/VBx/LblMsg.text += c
				yield($TimerTextVel,"timeout")
			#indicador de texto siguiente aparece con todo el texto mostrado
			$Control/BtnContinueIcon.visible = true
			
		"sprite":
			#c1 o c2
			get_node("Control/"+ln[2]).modulate.a = 0
			#sprite del personaje a colocar
			get_node("Control/"+ln[2]).texture = img_textures[ln[1]]
			#aparecer sprite con desvanecimiento
			$Tween.interpolate_property(get_node("Control/"+ln[2]),
				"modulate",Color(1,1,1,0),Color(1,1,1,1),0.5,
				Tween.TRANS_LINEAR,Tween.TRANS_LINEAR)
			$Tween.start()
			
		"hide_sprite":
			#desaparecer sprite con desvanecimiento
			$Tween.interpolate_property(get_node("Control/"+ln[1]),
				"modulate",Color(1,1,1,1),Color(1,1,1,0),0.5,
				Tween.TRANS_LINEAR,Tween.TRANS_LINEAR)
			$Tween.start()
			yield($Tween,"tween_completed")
			
		"focus":
			#oscurecer todos los sprites excepto al char especificado
			get_node("Control/c1").self_modulate = Color(0.47,0.47,0.47,1)
			get_node("Control/c2").self_modulate = Color(0.47,0.47,0.47,1)
			get_node("Control/"+ln[1]).self_modulate = Color(1,1,1,1)
			
		"focus_all":
			get_node("Control/c1").self_modulate = Color(1,1,1,1)
			get_node("Control/c2").self_modulate = Color(1,1,1,1)

	current_line += 1
	
	#si el statement de la linea es una de las siguientes, se avanzara automaticamente
	#a la siguiente linea
	if ln[0] in ["focus","focus_all","hide_sprite","sprite","wait_time","scene_bg","fade_in","fade_out","play_bgm","stop_bgm","play_sfx","stop_sfx","screen_shake"]:
		next_line()

#se ha presionado el boton para continuar el dialogo
func btn_next_line_pressed():
	if $Control/BtnContinueIcon.visible:
		next_line()
	else:
		$Control/BtnContinueIcon.visible = true

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and active:
		btn_next_line_pressed()
	elif Input.is_action_just_pressed("ui_select") and active:
		Audio.play_sfx("btn_cancel")
		set_process(false)
		hide_panel()

#se acabó el script...
func _on_DialogBox_script_ended():
	hide_panel()

#funcion para mostrar el panel de dialogo e iniciar el script
func show_panel(color_panel="red_light"):
	active = true
	$Control.modulate.a = 0
	$Control.visible = true
	ControlsOnscreen.show_buttons(false) #ocultar botones virtuales
	$Control/Margin/Panel.set_color_panel(color_panel)
	clear_screen()
	$Tween.interpolate_property($Control,
		"modulate",Color(1,1,1,0),Color(1,1,1,1),0.5,
		Tween.TRANS_LINEAR,Tween.TRANS_LINEAR)
	$Tween.start()
	yield($Tween,"tween_completed")
	begin()
	emit_signal("dialogbox_opened")

#ocultar panel
func hide_panel():
	$Tween.interpolate_property($Control,
		"modulate",Color(1,1,1,1),Color(1,1,1,0),0.5,
		Tween.TRANS_LINEAR,Tween.TRANS_LINEAR)
	$Tween.start()
	yield($Tween,"tween_completed")
	$Control.visible = false
	$Control.modulate.a = 1
	active = false
	set_process(false)
	#quitar pausa
	lvl_base = Functions.get_main_level_scene()
	if lvl_base != null:
		lvl_base.get_node("Hud").can_pause = true
	get_tree().paused = false
	emit_signal("dialogbox_closed")
	ControlsOnscreen.show_buttons_in_game()
