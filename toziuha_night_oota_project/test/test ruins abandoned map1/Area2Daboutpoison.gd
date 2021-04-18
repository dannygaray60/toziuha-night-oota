extends Area2D

var entered = false



func _on_Area2Daboutpotions_body_entered(body):
	if !entered and body.is_in_group("player"):
		entered = true
		
		if TranslationServer.get_locale()=="es":
			DialogBox.lines = [
				['say','none','Algunos enemigos pueden evenenarte.'],
				['say','none','Cuando tengas un estado [Poison] tu fuerza de ataque será reducida.'],
				['say','none','Para curarte puedes usar una poción, o esperar algunos segundos para curarte.'],
			]
		elif TranslationServer.get_locale()=="en":
			DialogBox.lines = [
				['say','none','Some enemies can poison you.'],
				['say','none','With a [Poison] state, your power attack will be decreased.'],
				['say','none','You can use a potion to heal the state or wait for a few seconds.'],
			]

		DialogBox.show_panel("purple_light")
