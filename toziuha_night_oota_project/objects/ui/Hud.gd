extends CanvasLayer

var can_pause = true

var hp_danger_bar_sprite = preload("res://assets/sprites/hp_bar_danger.png")
var hp_good_bar_sprite = preload("res://assets/sprites/hp_bar_good.png")

var subweapon_icons = {
	"none": null,
	"shuriken": preload("res://assets/sprites/subweapons_xandria_icons/icon1.png"),
	"axe": preload("res://assets/sprites/subweapons_xandria_icons/icon2.png"),
}

func _ready():
	
	$ControlPause.visible = false
	$Main.modulate.a = 1
	update_stats()
	
	
func _process(_delta):
	if can_pause and Input.is_action_just_pressed("ui_select") and !SceneChanger.changing_scene and !DialogBox.active:
		pause_game()
		
#	elif Input.is_action_just_pressed("ui_focus_next"):
#		show_titleroom()
		
func show_titleroom(txt="Name Room"):
#	can_pause = false
#	get_tree().paused = true
	Audio.play_sfx("cinematic_hit_reverse")
	$Main/ControlTitleRoom/PanelContainer/MarginContainer/Label.text = txt
	$Main/ControlTitleRoom/AnimationPlayer.play_backwards("hide")
	$Main/ControlTitleRoom/Timer.start()
	yield($Main/ControlTitleRoom/Timer,"timeout")
	$Main/ControlTitleRoom/AnimationPlayer.play("hide")
#	get_tree().paused = false
#	can_pause = true
	
func update_stats():
	
	#icono subweapon
	$Main/Texture/TextureSubweapon.texture = subweapon_icons[Vars.player["subweapon"]]
	
	#ocultar el panel del estado del jugador
	if Vars.player["condition"] == "good":
		$Main/Texture/TextureStatusPanel.visible = false
	else:
		$Main/Texture/TextureStatusPanel.visible = true
		
		
	#calcular cual es el porcentaje de vida, si es menos o igual a 20% entonces hay peligro
	var hp_percent = ( float(Vars.player["hp_now"])/float(Vars.player["hp_max"]) ) * 100
	if hp_percent <= 20:
		$Main/Texture/HPBar.texture_progress = hp_danger_bar_sprite
	else:
		$Main/Texture/HPBar.texture_progress = hp_good_bar_sprite
		
	$Main/Texture/HPBar.max_value = Vars.player["hp_max"]
	$Main/Texture/HPBar.value = Vars.player["hp_now"]
	$Main/Texture/EMBar.max_value = Vars.player["em_max"]
	$Main/Texture/EMBar.value = Vars.player["em_now"]
	$Main/Texture/LblPotionNum.text = str(Vars.player["potion_now"]).pad_zeros(2)
	$Main/Texture/TextureStatusPanel/LblStatus.text = Vars.player["condition"].capitalize()


func update_pause_stats():
	$ControlPause/MarginContainer2/HBoxContainer/LblAtk.text = "ATK: %s" % [str(Vars.player["atk"]).pad_zeros(2)]
	$ControlPause/MarginContainer2/HBoxContainer/LblDef.text = "DEF: %s" % [str(Vars.player["def"]).pad_zeros(2)]
	$ControlPause/MarginContainer2/HBoxContainer/LblHP.text = "HP: %s/%s" % [str(Vars.player["hp_now"]).pad_zeros(2),str(Vars.player["hp_max"]).pad_zeros(2)]
	$ControlPause/MarginContainer2/HBoxContainer/LblEM.text = "EM: %s/%s" % [str(Vars.player["em_now"]).pad_zeros(2),str(Vars.player["em_max"]).pad_zeros(2)]
	$ControlPause/MarginContainer2/HBoxContainer/LblCordova.text = "$%s" % [str(Vars.player["money"]).pad_zeros(5)]

	#llaves, cambiar la visibilidad de llaves dependiendo si ya se consiguieron
	for k in ["bronce_key","silver_key","golden_key"]:
		if Vars.player[k]:
			get_node("ControlPause/"+k).modulate = Color(1,1,1,1)
		else:
			get_node("ControlPause/"+k).modulate = Color(0.35,0.35,0.35,1)
	

func pause_menu_opt_selected(opt):
	match opt:
		"continue":
			pause_game()
		"saveandexit":
			ControlsOnscreen.show_buttons(false)
			Vars.set_vars()
			get_tree().paused = false
			SceneChanger.change_scene("res://screens/MainMenu.tscn")
		"help":
			$ControlPause/ControlHelp.visible = true
			$ControlPause/ControlHelp/Margin/HBx/VBx/BtnCloseHelpPanel.grab_focus()
		"close_help":
			$ControlPause/ControlHelp.visible = false
			$ControlPause/MarginContainer/HBoxContainer/BtnContinue.grab_focus()
func pause_game():
	#player muerto o con 0 hp no puede pausar juego
	if Vars.player["hp_now"] < 1 :
		return
	if get_tree().paused:
		$ControlPause/ControlHelp.visible = false
		Audio.play_sfx("btn_cancel")
		get_tree().paused = false
	else:
		Audio.play_sfx("btn_accept")
		get_tree().paused = true
	update_pause_stats()
	$ControlPause.visible = get_tree().paused
	$ControlPause/MarginContainer/HBoxContainer/BtnContinue.focus()
