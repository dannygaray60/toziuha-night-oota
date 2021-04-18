extends Control

var Conf = load("res://scripts/config.gd").new()

func _ready():
	
	match Conf.get_conf_value("video","filter","disabled"):
		"disabled":
			$VBoxContainer/Panel2/Margin/VBx/SubButton.focus()
		"scanlines":
			$VBoxContainer/Panel2/Margin/VBx/SubButton2.focus()
		"scanlines_curved":
			$VBoxContainer/Panel2/Margin/VBx/SubButton3.focus()
		"gameboy":
			$VBoxContainer/Panel2/Margin/VBx/SubButton4.focus()

func change_filter(opt):
	Conf.set_conf_value("video","filter",opt)
	FilterVideo._ready()

#regresar a opciones
func _on_SubButton_pressed():
	SceneChanger.change_scene("res://screens/Options.tscn")
