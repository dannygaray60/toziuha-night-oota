extends CanvasLayer

var visible_buttons = false

var Conf = load("res://scripts/config.gd").new()

func _ready():
	
	visible_buttons = Conf.get_conf_value("touchscreenbutton","show_buttons",false)
	
	show_buttons(false)
	
	var b_size = Conf.get_conf_value("touchscreenbutton","size",1)
	
	$Btn.modulate.a = Conf.get_conf_value("touchscreenbutton","opacity",1)
	$Dpad.modulate.a = Conf.get_conf_value("touchscreenbutton","opacity",1)
	
	for b in $Btn.get_children():
		b.position = Conf.get_conf_value("touchscreenbutton",b.name,Vector2(0,0))
		b.scale = Vector2(b_size,b_size)
		
	$Dpad.position = Conf.get_conf_value("touchscreenbutton","dpad",Vector2(0,0))
	$Dpad.scale = Vector2(b_size,b_size)

#mostrar u ocultar botones
func show_buttons(val=false):
	visible_buttons = Conf.get_conf_value("touchscreenbutton","show_buttons",false)
	for b in get_children():
		b.visible = val

#funcion para mostrar controles de acuerdo a la configuracion y que sean usados in-game
func show_buttons_in_game():
	release_all_buttons()
	visible_buttons = Conf.get_conf_value("touchscreenbutton","show_buttons",false)
	if visible_buttons:
		show_buttons(true)



func _on_Area2D_input_event(_viewport, event, _shape_idx,direction):
	if event is InputEventScreenTouch and event.pressed:
		Input.action_press("ui_"+direction)
		get_node("Dpad/ui_%s/TextureButton"%[direction]).pressed = true
	elif event is InputEventScreenTouch and !event.pressed:
		Input.action_release(("ui_"+direction))
		get_node("Dpad/ui_%s/TextureButton"%[direction]).pressed = false

func _on_Area2D_mouse_exited(direction):
	Input.action_release(("ui_"+direction))
	get_node("Dpad/ui_%s/TextureButton"%[direction]).pressed = false


func _on_Area2D_mouse_entered(direction):
	Input.action_press(("ui_"+direction))
	get_node("Dpad/ui_%s/TextureButton"%[direction]).pressed = true

#quitar pressed a todos los botones
func release_all_buttons():
	#quitar pressed a dpad
	for dp in $Dpad.get_children():
		Input.action_release(dp.name)
		dp.get_node("TextureButton").pressed = false