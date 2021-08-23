extends Area2D

#hacia donde se mueve el pendulo
var dir_mov = "center"

var original_player_camera_speed = 10

var player = null

func _ready():
	$Pendulum.set_start_position($Pendulum.global_position, $Position2D.global_position)
	$AnimatedSprite.animation = "moving"

func _physics_process(_delta):
	
	$Position2D.global_position = $Pendulum.end_position
	
	#mostrar cadena si el pendulo se puede mover
	$Line2D.visible = $Pendulum.move_pendulum
	#la punta del line2d coincidirá con la posicion2d (el final de la cadena)
	if $Line2D.visible:
		$Line2D.set_point_position(1,$Position2D.position)
	
	#cuando el jugador suelta el boton de ataque se suelta la cadena
	if player != null and !Input.is_action_pressed("ui_cancel"):
		chain_release()
	
	#mover jugador a la posicion del pendulo + ajuste
	if player != null and Input.is_action_pressed("ui_cancel"):
		player.position = $Pendulum.end_position + Vector2 (0,44) #35 42


func _process(_delta):
	
	#definir en que direccion va el pendulo
	if $Pendulum.angular_velocity > 0.04:
		dir_mov = "right"
	elif $Pendulum.angular_velocity < -0.04:
		dir_mov = "left"
	else:
		dir_mov = "center"
	#ScreenDebugger.dict["Chain_dir_X"] = dir_mov
	
	#si el jugador está enganchado la animacion cambia dependiendo
	#de direccion del pendulo
	if player != null:
		if dir_mov == "center" and player.anim_current != "hang-center":
			player.anim_state_machine.travel("hang-center")
		
		elif dir_mov == "left" and player.anim_current != "hang-left" and player.anim_current != "hang-left-center":
			if player.facing == 1:
				player.anim_state_machine.travel("hang-left")
			else:
				player.anim_state_machine.travel("hang-right")
		
		elif dir_mov == "right" and player.anim_current != "hang-right" and player.anim_current != "hang-right-center":
			if player.facing == 1:
				player.anim_state_machine.travel("hang-right")
			else:
				player.anim_state_machine.travel("hang-left")
	
#	ScreenDebugger.dict["Chain_dir_X"] = str( $Pendulum.angular_velocity )

#activar / desactivar todos los nodos chainswing en la escena
func disable_chain_swing_areas(val=true):
	for a in get_tree().get_nodes_in_group("chain_swing"):
		a.get_node("CollisionShape2D").set_deferred("disabled",val)

#soltar jugador del punto de apoyo
func chain_release():
	if player != null:
		Audio.play_sfx("chains2")
		$AnimatedSprite.animation = "moving"
		player.get_node("PlayerCamera").smoothing_speed = original_player_camera_speed
#		player.get_node("PlayerCamera").current = true
#		$PlayerCamera.current = false
		player.can_move = true
		player.whip_swing = false
		player.velocity.y = -350#-400
		player.anim_state_machine.start("jump")
		player = null
		$Pendulum.move_pendulum = false
		disable_chain_swing_areas(false)	
		

func _on_ChainSwingPoint_area_entered(area):
	if area.is_in_group("player_weapon") and player == null and Vars.player["hability_hook_whip"]:
		var player_direction = "left"
		player = area.get_parent().get_parent().get_parent()
		
		if abs(player.position.x - position.x) <= 0:
			player_direction = "center"
		elif player.position.x > position.x:
			player_direction = "right"
		
		if (player_direction == "left" and player.facing == -1) or (player_direction == "right" and player.facing == 1):
			player = null
			return
		
		
		
		Audio.play_sfx("chains2")
		$AnimatedSprite.animation = "default"
		disable_chain_swing_areas()
		player.change_state("idle")
		player.anim_state_machine.start("hang-center")
		player.can_move = false
		player.whip_swing = true
		$Position2D.global_position = player.global_position
		$Pendulum.set_start_position($Pendulum.global_position,$Position2D.global_position,0) #52.278
		$Pendulum.move_pendulum = true
		original_player_camera_speed = player.get_node("PlayerCamera").smoothing_speed
		player.get_node("PlayerCamera").smoothing_speed = 3
#		$PlayerCamera.current = true
		
