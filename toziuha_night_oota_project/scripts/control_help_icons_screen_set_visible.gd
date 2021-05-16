extends Control

#pequeño script para ocultar las cajas
#que indican los iconos de botones en las pantallas

func _ready():
	
	if ControlsOnscreen.visible_buttons:
		self.visible = false
