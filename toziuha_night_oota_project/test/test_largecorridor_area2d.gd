extends Area2D

var detect = true

func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and detect:
		detect = false
		DialogBox.lines = [
			['say','none','Presiona "aceptar" para continuar el mensaje.'],
			['focus','c2'],
			['sprite','xandria_normal','c2'],
			['say','x','Este es un mensaje de ejemplo...'],
			['focus','c1'],
			['sprite','rachel_normal','c1'],
			['say','r','Y este es otro mensaje. Luego se ocultará los sprites.'],
			['say','r','Lorem ipsum dolor sit amet consectetur adipiscing elit luctus, facilisi congue consequat iaculis sagittis...'],
			['hide_sprite','c1'],
			['hide_sprite','c2'],
			['say','none','Ocultando panel y finalizando...'],
		]
		DialogBox.show_panel()
