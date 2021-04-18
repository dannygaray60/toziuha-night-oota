extends Area2D

var entered = false



func _on_Area2Daboutpotions_body_entered(body):
	if !entered and body.is_in_group("player"):
		entered = true
		
		if TranslationServer.get_locale()=="es":
			DialogBox.lines = [
				['say','none','Puedes usar pociones para curar salud.'],
				['say','none','Para usarlas mantén presionado [Abajo] y presiona el botón de [Esquivar] al mismo tiempo.'],
				['say','none','Recuperarás salud lentamente pero si atacas, te deslizas, esquivas o recibes daño, la curación se interrumpe.'],
				['say','none','Al estar agachado, el efecto de curación se duplica.'],
				['say','none','Solo puedes llevar un número limitado de pociones.'],
				['say','none','Consulta el menú de ayuda (al hacer pausa) para conocer la lista de acciones.'],
			]
		elif TranslationServer.get_locale()=="en":
			DialogBox.lines = [
				['say','none','You can use potions to recover health.'],
				['say','none','Use a potion holding [Down] and press [Backdash] button at same time.'],
				['say','none','You will recover health slowly, but if you attack, slide, backdash or receive damage, the effect will disapear.'],
				['say','none','When you are crouching, the curation effect is duplicated.'],
				['say','none','You can get a limited number of potions.'],
				['say','none','Check the help menu (on pause screen) to see the action list.'],
			]

		DialogBox.show_panel("purple_light")
