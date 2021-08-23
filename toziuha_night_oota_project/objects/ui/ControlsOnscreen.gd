extends CanvasLayer

var visible_buttons = false

var Conf = load("res://scripts/config.gd").new()

func _ready():
	
	visible_buttons = Conf.get_conf_value("touchscreenbutton","show_buttons",false)
	
	show_buttons(false)
	
	var b_size = Conf.get_conf_value("touchscreenbutton","size",1)
	
	$Btn.modulate.a = Conf.get_conf_value("touchscreenbutton","opacity",1)
	$Dpad.modulate.a = Conf.get_conf_value("touchscreenbutton","opacity",1)
	
	#aplicar posicion y scale primero a btn de manera individual
	#y luego a dpad como un solo ente
	for b in $Btn.get_children():
		b.position = Conf.get_conf_value("touchscreenbutton",b.name,Vector2(0,0))
		b.scale = Vector2(b_size,b_size)
	$Dpad.position = Conf.get_conf_value("touchscreenbutton","dpad",Vector2(0,0))
	$Dpad.scale = Vector2(b_size,b_size)
	
	#colocar shapes a los botones del dpad
	for dp in $Dpad.get_children():
		if dp.name in ["ui_left","ui_right"]:
			dp.get_node("Btn").shape.points = $DpadButtonShape2.polygon
		else:
			dp.get_node("Btn").shape.points = $DpadButtonShape.polygon

#mostrar u ocultar botones
func show_buttons(val=false):
	#visible_buttons = Conf.get_conf_value("touchscreenbutton","show_buttons",false)
	for b in get_children():
		b.visible = val

#funcion para mostrar controles de acuerdo a la configuracion y que sean usados in-game
func show_buttons_in_game():
	visible_buttons = Conf.get_conf_value("touchscreenbutton","show_buttons",false)
	if visible_buttons:
		show_buttons(true)
