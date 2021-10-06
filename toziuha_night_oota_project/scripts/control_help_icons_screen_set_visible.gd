extends Control

var Conf = load("res://scripts/config.gd").new()

#pequeño script para ocultar las cajas
#que indican los iconos de botones en las pantallas

func _ready():
	
	if OS.has_touchscreen_ui_hint() and Conf.get_conf_value("video","icons_buttons","hide") != "gamepad":
		self.visible = false
