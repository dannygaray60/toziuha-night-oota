extends Area2D

var entered = false



func _on_AreaShowRachelDialogue_body_entered(body):
	if !entered and body.is_in_group("player"):
		entered = true
		
		if TranslationServer.get_locale()=="es":
			DialogBox.lines = [
				['focus','c1'],
				['sprite','rachel_normal','c1'],
				['sprite','xandria_normal','c2'],
				['say','r','Buen trabajo, Xandria. Has terminado tu práctica.'],
				['focus','c2'],
				['say','x','¿Eso fue todo? No estuvo tan difícil...'],
				['focus','c1'],
				['say','r','¿Oh? ¿Así que quieres un reto mayor?'],
				['say','r','Entonces, es hora de que yo pelee contigo.'],
				['say','r','...'],
				['say','r','Ju, ju, ju, solo bromeaba. Mi momento para pelear no será hoy.'],
				['say','r','Eso es todo por el momento.'],
				['hide_sprite','c1'],
				['hide_sprite','c2'],
				['say','none','Recuerda seguir las redes sociales del proyecto.'],
				['say','none','Los links están en el menú "Créditos".'],
				['say','none','También te invito a dejar un donativo (o ser patreon) para apoyar el desarrollo.'],
				['say','none','Pero también puedes reportar bugs o dejar sugerencias.'],
				['say','none','Nos vemos en la siguiente demo.'],
			]
		elif TranslationServer.get_locale()=="en":
			DialogBox.lines = [
				['focus','c1'],
				['sprite','rachel_normal','c1'],
				['sprite','xandria_normal','c2'],
				['say','r','Good job, Xandria. You have finished your practice.'],
				['focus','c2'],
				['say','x',"Was that all? It wasn't that hard..."],
				['focus','c1'],
				['say','r','Oh? So you want a bigger challenge?'],
				['say','r',"Then it's time for me to fight you."],
				['say','r','...'],
				['say','r','Fu, fu, fu, just kidding. My time to fight will not be today.'],
				['say','r',"That's all for now."],
				['hide_sprite','c1'],
				['hide_sprite','c2'],
				['say','none',"Remember to follow the game's social networks."],
				['say','none','The links are in the "Credits" menu.'],
				['say','none','I also invite you to leave a donation (or become a patreon) to support the development.'],
				['say','none','But you can also report bugs or leave suggestions.'],
				['say','none','See you in the next demo.'],
			]

		DialogBox.show_panel()
