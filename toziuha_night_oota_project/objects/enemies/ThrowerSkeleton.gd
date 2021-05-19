extends KinematicBody2D

var bone = preload("res://objects/EnemyBoneProyectile.tscn")
var bone_instance = null

export var id = "skeleton"

#puntos de salud
var hp_max = 0
var hp_now = 0

var jump_speed = 190

#items que deja al morir
var list_items = []

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

var facing = -1

var gravity = 600
var speed = 60

var state = "idle"

#nodo del player
var player = null

var chasing = false

#funcion para comprobar la posicion de personaje y colocar el facing 
#de frente al jugador
func update_facing():

	if $TimerToChangeFacing.get_time_left() == 0 and state != "dead":
		
		$TimerToChangeFacing.start(0.5)

		facing = Functions.get_new_facing_with_player(self,player)

		#volteo de sprite
		$Sprite.scale.x = -1 * facing

func _ready():
	
	player = Functions.get_main_level_scene().get_player()
	
	update_facing()

	change_state("throw")
	
	#colocar stats de vida
	hp_max = Vars.enemy[id]["hp_max"]
	hp_now = hp_max
	#items que deja al morir
	list_items = Vars.enemy[id]["item_drop"]
	
func _physics_process(delta):
	
	#si el jugador pasa encima o debajo del enemigo
	#se invertirá el facing mediante timer
	if player:
		var distance_to_enemy = player.global_position.x - global_position.x
		if distance_to_enemy >= -5 and distance_to_enemy <= 5:
			$TimerToChangeFacing.start(0.5)
			
	match state:
		"walk":
			velocity.x = speed*facing
			if $AnimationPlayer.current_animation != "walk":
				state == "idle"
				change_state("walk")
		"idle":
			velocity.x = 0

	#gravedad
	velocity.y += gravity*delta
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	if is_on_wall() and is_on_floor():
		if facing == 1:
			facing = -1
		else:
			facing = 1
		$Sprite.scale.x = facing * -1
	
	#-------------- deteccion de colisiones ----------------------
	if state!="dead":
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			#si colisiona contra jugador
			if collision.collider.is_in_group("player"):
				collision.collider.hurt(id,position)
					
	if state == "dead" and is_on_floor():
		gravity = 0
		velocity.y = 0
		$CollisionShape2D.disabled = true

func hurt(damage,weapon_position):
	if $TimerHurt.get_time_left() == 0:
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()
		change_state("idle")
		velocity.x = 0

		Audio.play_sfx("hit4")
		
		#damage calcule
		#reducir damage gracias a defensa
		damage = Functions.get_value(damage,"-",Vars.enemy[id]["def"])
		hp_now -= damage
		
		var indicator_position = Vector2(global_position.x,weapon_position.y)
		Functions.show_damage_indicator(damage,indicator_position,"red")
		
		if hp_now <= 0:
			die()

func die():
	if state != "dead":
		
		change_state("dead")
		velocity.x = 0
		
		#desactivar colisiones
		set_collision_layer_bit(2,false)
		set_collision_mask_bit(0,false)
		set_collision_mask_bit(4,false)
		
		
		Audio.play_sfx("smash_wood_pieces")
		
		#mostrar el nombre del enemigo eliminado
		Functions.show_hud_notif(tr(Vars.enemy[id]["name"]))
		
		#spawnear item como recompensa
		if !list_items.empty():
			randomize()
			list_items.shuffle()
			Functions.spawn_drop_item(list_items[randi()%list_items.size()-1],position)

#cambio de estados
func change_state(new_state):
	#no podrá regresar a estado de caminar si no está en pantalla
	if state == "dead":
		return
	
	match new_state:
		"idle":
			velocity.x = 0
			velocity.y = 0
	$AnimationPlayer.play(new_state)
	state = new_state
	
func throw_bone():
	if state != "dead" and $VisibilityEnabler2D.is_on_screen():
		bone_instance = bone.instance()
		bone_instance.global_position = $Sprite/PosSpawnBone.global_position
		bone_instance.direction = facing
		if $Sprite/RayCastDetectPlayerFront.is_colliding():
			bone_instance.linear_direction = true
		Functions.get_main_level_scene().add_child(bone_instance)
		update_facing()
		
		
#un pequeño salto hacia atrás a manera de esquivar
func jump(back=false):
	if state == "dead":
		return
		
	if back and ($Sprite/RayCastDetectBackWall.is_colliding() or !$Sprite/RayCastDetectBackNoFloor.is_colliding() ):
		jump()
		return
		
	if !$Sprite/RayCastDetectFrontNoFloor.is_colliding() and !back:
		return
		
	if back:
		velocity.x = -50*facing
	else:
		velocity.x = 50*facing

	velocity.y = -300
	$TimerJumpBack.start()

#entra o sale de pantalla (o que este cerca)
func _on_VisibilityEnabler2D_screen_entered():
	update_facing()

func _on_VisibilityEnabler2D_screen_exited():
	change_state("idle")
	update_facing()

#cambiar facing mediante timer activado en physics process
func _on_TimerToChangeFacing_timeout():
	update_facing()

#player entró en area de deteccion del enemigo
func _on_AreaDetectPlayer_body_entered(body):
	if body.is_in_group("player") and state != "dead":
		chasing = true
		change_state("walk")
#o salió
func _on_AreaDetectPlayer_body_exited(body):
	if body.is_in_group("player") and state != "dead":
		chasing = false
		#change_state("idle")


func _on_TimerHurt_timeout():
	$Sprite.modulate = Color(1,1,1,1)
	if state != "dead":
		update_facing()
		jump(true)
		change_state("walk")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"dead":
			$Sprite.modulate = Color(1,1,1,1)
			queue_free()

func on_player_death():
	if state != "dead":
		change_state("idle")


func _on_AreaDetectNearPlayer_body_entered(body):
	if body.is_in_group("player") and is_on_floor() and state != "walk" and state != "dead":
		update_facing()
		jump(true)


func _on_TimerJumpBack_timeout():
	if state != "dead":
		update_facing()
		#if state != "walk":# and is_on_floor():
		velocity.x = 0


func _on_AreaDetectPlayerFront_body_entered(body):
	if state != "dead" and body.is_in_group("player") and is_on_floor() and $VisibilityEnabler2D.is_on_screen():
		update_facing()
		change_state("walk")


func _on_AreaDetectPlayerFront_body_exited(body):
	if state == "dead":
		return

	if body.is_in_group("player"):
		
		
		if $VisibilityEnabler2D.is_on_screen():
			velocity.x = 0
			change_state("throw")
#		else:
#			change_state("idle")
			
		update_facing()


func _on_AreaDetectObstacle_body_entered(body):
	if body is TileMap and is_on_floor() and state != "dead":
		update_facing()
		jump()


func _on_AreaDetectNoFloor_body_exited(body):
	if body is TileMap and state != "dead":
#		velocity.x = 0
		change_state("throw")
