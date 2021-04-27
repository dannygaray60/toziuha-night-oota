extends Node2D

var player = null

var open = false

#al cerrarse la puerta no volverá a abrirse hasta la muerte del jefe
export var boss_lock = false

export(String, "bronze","silver","golden", "boss") var type_door = "bronze"

func _ready():
	
	$door_special_up/Body/CollisionShape2D.disabled = true
	$door_special_down/Body/CollisionShape2D.disabled = true
	
	
	match type_door:
		
		"bronze":
			$door_special_up.frame = 2
			$door_special_down.frame = 2
		"silver":
			$door_special_up.frame = 3
			$door_special_down.frame = 3
		"golden":
			$door_special_up.frame = 4
			$door_special_down.frame = 4
		"boss":
			$door_special_up.frame = 5
			$door_special_down.frame = 5
		

func shake_camera():
	if player != null:
		player.get_node("PlayerCamera").add_trauma(0.2,true)

func _on_Area2D_body_entered(body):
	
	if body.is_in_group("player") and !open:
		#con este timer podemos comprobar si el cuerpo del jugador
		#se instancia encima de la puerta
		#en este caso la puerta desaparecerá
		if $Timer.get_time_left() == 0.5:
			open = true
			$AnimationPlayer.play("opened")
			return
		
		#con este bloque hacemos uso del mismo timer
		#para evitar que se active el resto del codigo en el mismo frame
		#(evitar señal duplicada) sin tener que usar oneshot en señal	
		if $Timer.get_time_left() != 0:
			return
		$Timer.start()
		player = body
		if type_door in ["bronze","silver","golden"] and !Vars.player[type_door+"_key"]:
			DialogBox.lines = [['say','none',tr("LOCKEDDOOR")],]	
			DialogBox.show_panel("purple_light")
			return

		open = true
		$AnimationPlayer.play("open")


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "open":
		Audio.stop_sfx("door_closed")
		Audio.stop_sfx("door_opening")
		Audio.play_sfx("door_opening")


func _on_AnimationPlayer_animation_finished(_anim_name):
	Audio.stop_sfx("door_opening")
	Audio.play_sfx("door_closed")

func _on_Timer_timeout():
	if !open:
		$door_special_up/Body/CollisionShape2D.disabled = false
		$door_special_down/Body/CollisionShape2D.disabled = false


func _on_Area2D_body_exited(body):
	if open and body.is_in_group("player"):
		player = null
		$AnimationPlayer.play_backwards("open")
		open = false


func _on_DoorSpecial_tree_exiting():
	Audio.stop_sfx("door_opening")
	Audio.stop_sfx("door_closed")
