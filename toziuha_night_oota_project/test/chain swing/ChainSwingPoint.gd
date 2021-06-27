extends Area2D

var player = null

func _ready():
	
	$Pendulum.set_start_position($Pendulum.global_position, $Position2D.global_position)

func _physics_process(_delta):
	
	$Position2D.global_position = $Pendulum.end_position
	
	#mostrar cadena si el pendulo se puede mover
	$Line2D.visible = $Pendulum.move_pendulum
	#la punta del line2d coincidirá con la posicion2d (el final de la cadena)
	if $Line2D.visible:
		$Line2D.set_point_position(1,$Position2D.position)
	
	#cuando el jugador suelta el boton de ataque se suelta la cadena
	if player != null and Input.is_action_just_released("ui_cancel"):
		player.can_move = true
		player.whip_swing = false
		player.velocity.y = -400
		player.anim_state_machine.start("jump")
		player = null
		$Pendulum.move_pendulum = false
	
	#mover jugador a la posicion del pendulo + ajuste
	if player != null and Input.is_action_pressed("ui_cancel"):
		player.position = $Pendulum.end_position + Vector2 (0,35)

func _on_ChainSwingPoint_area_entered(area):
	if area.is_in_group("player_weapon") and player == null:
		player = area.get_parent().get_parent().get_parent()
		player.change_state("idle")
		player.can_move = false
		player.whip_swing = true
		$Pendulum.move_pendulum = true
