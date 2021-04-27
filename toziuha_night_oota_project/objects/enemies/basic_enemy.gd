extends KinematicBody2D

export(String, "simple","chaser") var type_pattern = "simple"

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
func check_player_position():
	#agregar referencia del jugador
	if player == null:
		player = get_tree().get_nodes_in_group("player")
		#si no se ha agredado un solo jugador...
		if player.size() == 1:
			#get the player's node
			player = player[0]
			#conectar señal de muerte
			player.connect("dead",self,"on_player_death")
		else:
			player = null
	#hacer comprobacion de posicion
	if player != null and state != "dead":
		if player.global_position.x > global_position.x:
			facing = 1
		else:
			facing = -1

	#volteo de sprite
	$Sprite.scale.x = -1 * facing
	
	$Sprite/RayCastFront.enabled = false

	if type_pattern == "chaser":
		change_state("walk")

func _ready():
	check_player_position()
	if type_pattern == "simple":
		change_state("walk")
	else:
		change_state("idle")
		
	if id in ["zombie","slime","infected_slime"]:
		speed = 30
	
	#colocar stats de vida
	hp_max = Vars.enemy[id]["hp_max"]
	hp_now = hp_max
	#items que deja al morir
	list_items = Vars.enemy[id]["item_drop"]
	
func _physics_process(delta):
	
	#si el jugador pasa encima o debajo del enemigo
	#se invertirá el facing mediante timer
	if player and type_pattern != "simple":
		var distance_to_enemy = player.global_position.x - global_position.x
		if distance_to_enemy >= -5 and distance_to_enemy <= 5:
			$TimerToChangeFacing.start(0.5)
			
	if state=="walk":
		velocity.x = speed*facing

	#gravedad
	velocity.y += gravity*delta
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	if type_pattern == "simple":
		if is_on_wall() and is_on_floor():
			if facing == 1:
				facing = -1
			else:
				facing = 1
			$Sprite.scale.x = facing * -1

	else:
		if chasing and state == "idle" and !$Sprite/RayCastFront.is_colliding():
			change_state("walk")
		#choque de pared pero hay espacio para saltar por encima (determinado por raycast)
		if is_on_wall() and is_on_floor() and !$Sprite/RayCastFront.is_colliding():
			velocity += Vector2.UP * jump_speed
		if state == "walk" and $Sprite/RayCastFront.is_colliding():
			#al chocar poner idle, el enemigo a veces no se mueve
			#cuando detecta jugador, por eso se desactiva el raycas
			#y se activa de nuevo al voltear sprite
			#en check_player_position
			$Sprite/RayCastFront.enabled = false
			change_state("idle")
		else:
			$Sprite/RayCastFront.enabled = true
	
	#-------------- deteccion de colisiones ----------------------
	if state!="dead":
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			#si colisiona contra jugador
			if collision.collider.is_in_group("player"):
				collision.collider.hurt(id,position)
				#si este cuerpo lleva veneno
				if self.is_in_group("poison"):
					collision.collider.change_condition("poison")
					
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
		
		if id in ["skeleton","infected_skeleton"]:
			Audio.play_sfx("hit4")
		elif id in ["zombie"]:
			Audio.play_sfx("knife_stab")
		elif id in ["slime","infected_slime"]:
			Audio.play_sfx("hit2")
		
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
		velocity.x = 0
		change_state("dead")
		if id in ["skeleton","infected_skeleton"]:
			Audio.play_sfx("smash_wood_pieces")
		elif id in ["zombie"]:
			pass #tal vez un gruñido al morir...
		elif id in ["slime","infected_slime"]:
			Audio.play_sfx("hit3")
		
		#spawnear item como recompensa
		Functions.spawn_drop_item(list_items[0],position)
		#mostrar el nombre del enemigo eliminado
		Functions.show_hud_notif(tr(Vars.enemy[id]["name"]))
		
		#desactivar colisiones
		set_collision_layer_bit(2,false)
		set_collision_mask_bit(0,false)
		set_collision_mask_bit(4,false)
		set_collision_layer_bit(2,false)
		
		#spawnear item como recompensa
		if !list_items.empty():
			randomize()
			list_items.shuffle()
			Functions.spawn_drop_item(list_items[0],position)

#cambio de estados
func change_state(new_state):
	#no podrá regresar a estado de caminar si no está en pantalla
	if (new_state == "walk" and $Sprite/RayCastFront.is_colliding()) or new_state == state or state == "dead":
		return
	match new_state:
		"idle":
			velocity.x = 0
			velocity.y = 0
	$AnimationPlayer.play(new_state)
	state = new_state

#entra o sale de pantalla (o que este cerca)
func _on_VisibilityEnabler2D_screen_entered():
	check_player_position()

func _on_VisibilityEnabler2D_screen_exited():
	pass

#cambiar facing mediante timer activado en physics process
func _on_TimerToChangeFacing_timeout():
	check_player_position()

#player entró en area de deteccion del enemigo
func _on_AreaDetectPlayer_body_entered(body):
	if body.is_in_group("player") and type_pattern != "simple":
		chasing = true
		change_state("walk")
#o salió
func _on_AreaDetectPlayer_body_exited(body):
	if body.is_in_group("player") and type_pattern != "simple":
		chasing = false
		change_state("idle")


func _on_TimerHurt_timeout():
	$Sprite.modulate = Color(1,1,1,1)
	change_state("walk")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"dead":
			$Sprite.modulate = Color(1,1,1,1)
			queue_free()

func on_player_death():
	change_state("idle")
