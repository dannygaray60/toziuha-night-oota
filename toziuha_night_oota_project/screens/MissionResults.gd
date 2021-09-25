extends Control

func _ready():
	
	#ocultar botones
	ControlsOnscreen.show_buttons(false)
	
	Audio.play_sfx("boss_orb_generated2")
	$PanelActions/HBx/BtnContinue.focus()

	$PanelDetails/Margin/VBx/HBxRecolectedMoney/Lbl2.text = str(Vars.player["money"]).pad_zeros(6)

	$PanelDetails/Margin/VBx/HBxDeaths/Lbl2.text = str(Vars.player["deaths"])

	#agregar el dinero recolectado a la partida principal
	#---- (pendiente)
	
	#eliminar datos de partida
	Savedata.delete_savedata("savegame")
	#reiniciar variables
	Vars.set_vars()

func _on_BtnContinue_pressed():
	SceneChanger.change_scene("res://screens/SelectMap.tscn")
