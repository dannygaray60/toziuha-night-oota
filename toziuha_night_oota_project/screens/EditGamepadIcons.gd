extends Control

var action_to_reasign = ""
var selected_btn = ""

var Conf = load("res://scripts/config.gd").new()

func _process(_delta):
	
	if Input.is_action_just_pressed("ui_cancel") and $Margin/HBx/Margin.visible:
		Audio.play_sfx("btn_cancel")
		get_node("Margin/HBx/VBx/Panel/Margin/VBx/%s/Btn"%[selected_btn]).focus()
		$Margin/HBx/Margin.visible = false
		$Margin/HBx/VBx/Panel0.visible = true
		$Margin/HBx/VBx/Panel.visible = true
		$Margin/HBx/VBx/PanelLbl.visible = false
		$Margin/HBx/VBx/HSeparator.visible = false
	elif Input.is_action_just_pressed("ui_cancel") and !$Margin/HBx/Margin.visible:
		Audio.play_sfx("btn_cancel")
		$Margin/HBx/VBx/Panel0/Margin/VBx/BtnMenu.focus()

func _ready():
	
	#ocultar panel con los iconos disponibles
	$Margin/HBx/Margin.visible = false
	
	$Margin/HBx/VBx/PanelLbl.visible = false
	$Margin/HBx/VBx/HSeparator.visible = false
	
	$Margin/HBx/VBx/Panel/Margin/VBx/BtnJump/Btn.focus()

	#recorrer la lista de botones de iconos
	for b in $Margin/HBx/Margin/PanelIcons/Margin/GridBtns.get_children():
		b.get_node("Sprite").frame = int(b.name)
		b.connect("pressed",self,"selected_icon",[int(b.name)])
		b.connect("focus_entered",self,"btn_icon_focus")

func btn_icon_focus():
	Audio.play_sfx("btn_move")
	
func reasign_icon_button(action,namebtn):
	selected_btn = namebtn #para regresarle el focus después
	action_to_reasign = action
	#dar focus a nuevo boton
	get_node("Margin/HBx/Margin/PanelIcons/Margin/GridBtns/%s"%[str(Conf.get_conf_value("gamepad_icon",action,0))]).grab_focus()
	#actualizar mensaje de ayuda
	get_node("Margin/HBx/VBx/PanelLbl/Margin/Label").text = tr("SELECTNEWBTNICONFORX")%[namebtn]
	$Margin/HBx/Margin.visible = true
	$Margin/HBx/VBx/Panel0.visible = false
	$Margin/HBx/VBx/Panel.visible = false
	$Margin/HBx/VBx/PanelLbl.visible = true
	$Margin/HBx/VBx/HSeparator.visible = true

#se ha seleccionado un icono
#que reemplazará el boton asignado
func selected_icon(num_icon):
	Conf.set_conf_value("gamepad_icon",action_to_reasign,num_icon)
	Audio.play_sfx("btn_accept")
	get_node("Margin/HBx/VBx/Panel/Margin/VBx/%s/Btn"%[selected_btn]).focus()
	$Margin/HBx/Margin.visible = false
	$Margin/HBx/VBx/Panel0.visible = true
	$Margin/HBx/VBx/Panel.visible = true
	$Margin/HBx/VBx/PanelLbl.visible = false
	$Margin/HBx/VBx/HSeparator.visible = false
	#actualizar iconos de los helpers por si acaso
	for b in get_tree().get_nodes_in_group("btn_help_icon"):
		b.update_icon()

func _on_BtnMenu_pressed():
	SceneChanger.change_scene("res://screens/Options.tscn")
