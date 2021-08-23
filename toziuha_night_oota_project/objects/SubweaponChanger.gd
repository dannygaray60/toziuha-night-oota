extends RigidBody2D

export var subweapon = "shuriken"

var prev_subweapon = "none"

func _ready():

	if subweapon == Vars.player["subweapon"] or subweapon == "none":
		queue_free()
		return
		
	match subweapon:
		"shuriken":
			$subweapons_xandria.frame = 0
		"axe":
			$subweapons_xandria.frame = 1



#mostrar
func _on_Timer_timeout():
	$subweapons_xandria.modulate.a = 1



func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and $subweapons_xandria.modulate.a == 1:
		Audio.play_sfx("item_pick2")
		prev_subweapon = Vars.player["subweapon"]
		Vars.player["subweapon"] = subweapon
		subweapon = prev_subweapon
		body.emit_signal("stats_changed")
		$subweapons_xandria.modulate.a = 0.5
		$Timer.start()
		_ready()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
