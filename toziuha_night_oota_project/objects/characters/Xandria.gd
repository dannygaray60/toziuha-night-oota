extends KinematicBody2D

signal dead
signal damaged
signal stamina_loss

var blood_particle = preload("res://objects/particles/BloodParticle.tscn")
var blood_particle_instance = null

var damage_indicator = preload("res://objects/ui/DamageIndicator.tscn")
var damage_indicator_instance = null

const FLOOR_NORMAL = Vector2.UP
const SNAP_DIRECTION = Vector2.DOWN
const SNAP_LENGTH = 10#32.0 #se cambio a 10, para evitar que al caer de una baja altura, el cuerpo se pegue inmediatamente al suelo
#el limite de grados en el que un objeto es considerado suelo
const SLOPE_THRESHOLD = deg2rad(46)

#velocidad de movimiento
var velocity = Vector2(0,0)
#direcion en x o y
var direction = Vector2(0,0)

#para activar o desactivar snap
var snap_vector = SNAP_DIRECTION * SNAP_LENGTH

#no resbalar en pendientes?
var stop_on_slope = true

#afecta velocidad de caida desde precipicio
export var fall_multiplier = 3
#este afecta que tan alto salta con solo haber presionado boton,
#en relacion con la gravedad
export var low_jump_multiplier = 300
#la cantidad de pixeles que sumara el salto al personaje (distancia de salto)
export var jump_velocity = 280
#valor de la gravedad
export var gravity = 700
#velocidad para desplazamiento
export var speed = 100

#cantidad de saltos realizados
var num_jumps = 0

#cantidad de ataques realizados, un máximo de 3
var num_attacks = 0

export var acceleration = 0.1
export var friction = 0.2

#------- Habilidades
export var can_double_jump = false
export var can_slide = false
export var can_backdash = false

#multiplica el valor para moverse en horizontal,
#si es 2, se duplica la velocidad
var run_vel_multiplier = 1

#estados del jugador: idle, walk, run, jump, fall, attack, backdash, slide
var state = "idle"

#guardar animationtree
var anim_state_machine
#la animacion dentro de animationtree
var anim_current

#hacia cual direccion mira el jugador
var facing = 1

var was_on_floor = true

#el jugador está en una plataforma semisolida?
var is_on_onewaycol = false

func _ready():
	set_body_collision()
	anim_state_machine = $AnimationTree.get("parameters/playback")
	anim_current = anim_state_machine.get_current_node()

#debug
func _process(_delta):
	ScreenDebugger.dict["State"] = state
	ScreenDebugger.dict["Anim"] = str( anim_current )
	ScreenDebugger.dict["Jumps"] = str( num_jumps )
	ScreenDebugger.dict["Vel_X"] = str( round(velocity.x) )
	ScreenDebugger.dict["Vel_Y"] = str( round(velocity.y) )
	ScreenDebugger.dict["Dir_X"] = str( round(direction.x) )
	ScreenDebugger.dict["Facing"] = str( facing )
	ScreenDebugger.dict["Scale_X"] = str( $Sprite.scale.x )
	ScreenDebugger.dict["OnFloor"] = str( is_on_floor() )
	ScreenDebugger.dict["OnWall"] = str( is_on_wall() )
	ScreenDebugger.dict["RycastDown"] = str( $Sprite/RayCastDown.is_colliding() )
	


func _physics_process(delta):
	
	was_on_floor = is_on_floor()
	
	anim_current = anim_state_machine.get_current_node()
	
	#se cambiará la direccion solo si no está la animacion changedir en reproduccion
	if direction.x != 0 and state != "backdash" and state != "attack" and state != "attack-crouch":
		change_direction(direction.x)
		facing = direction.x
	
	if state != "hurt":
		_get_input()
	
	#gravedad
	velocity.y += gravity*delta
	
	#movimiento general en Y
	velocity.y = move_and_slide_with_snap(velocity,snap_vector,FLOOR_NORMAL,stop_on_slope,4,SLOPE_THRESHOLD).y
	
	#nota: por alguna razón raycastdown funciona al revés no tengo idea
	
	#movimiento automatico en backdash
	if state == "backdash" and is_on_floor():
		if !$Sprite/RayCastDown.is_colliding():
			velocity.x -= (40 * facing)
		else:
			velocity.x -= (15 * facing)
			
	#y movimiento para slide
	if state == "slide" and is_on_floor():
		if !$Sprite/RayCastDown.is_colliding():
			velocity.x += (40 * facing)
		else:
			velocity.x += (8 * facing)
		
	_check_states()
	
	#comprobar en cada frame si tocamos suelo por primera vez
	#(luego de haber estado en el aire
	if is_on_floor() and !was_on_floor:
		Audio.play_sfx("foot_floor")
		
	#-------------- deteccion de colisiones con enemigos o plataformas ----------------------
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		
		#detectar colision oneway
		if collision.collider is TileMap:
			var tile_pos = collision.collider.world_to_map(position)
			tile_pos -= collision.normal
			var tile_id = collision.collider.get_cellv(tile_pos)
			if tile_id >= 0:
#				var tile_name = collision.collider.tile_set.tile_get_name(tile_id)
				#si estamos sobre un tile con onewaycolision
				is_on_onewaycol = collision.collider.tile_set.tile_get_shape_one_way(tile_id,0)
		
		
		if collision.collider.is_in_group("enemies"):
			var cpos = collision.collider.get_position()
			hurt(collision.collider.id,cpos)


func _get_input():
	
	#movimiento con teclas siempre y cuando no estemos heridos
	
	# --------- detectar entrada de tecla izq o der para movimiento horizontal ----------
#	direction.x = int( Input.is_action_pressed('ui_right') ) - int( Input.is_action_pressed('ui_left') )
	#metodo alternativo
	if Input.is_action_pressed("ui_left") and state != "backdash" and state != "slide":
		direction.x = -1
	elif Input.is_action_pressed("ui_right") and state != "backdash" and state != "slide":
		direction.x = 1
	else:
		direction.x = 0

	_move()
	
	#agacharse
	if Input.is_action_pressed("ui_down") and is_on_floor() and state != "slide" and state != "attack-crouch" and state != "attack":
		_crouch()
	elif Input.is_action_just_released("ui_down") and state == "crouch":
		if !$Sprite/RayCastUp.is_colliding():
			change_state("idle")
		
	#acción de ataque	
	if Input.is_action_just_pressed("ui_cancel"):
		_attack()
		
	#accion para arroja un item curativo
	if Input.is_action_pressed("ui_up") and Input.is_action_just_pressed("ui_accept"):
		_throw_health_item()
		
		
	#salto
	if Input.is_action_just_pressed("ui_accept") and !Input.is_action_pressed("ui_up"):
		_jump()
	else:
		#si no pulsamos btn salto, hay snap para pegar al jugador al suelo inclinado
		snap_vector = SNAP_DIRECTION * SNAP_LENGTH
	
	# esquive hacia atrás (backdash)
	if Input.is_action_just_pressed("ui_focus_prev") and can_backdash:
		_backdash()
		
	#slide
	if is_on_floor() and Input.is_action_pressed("ui_down") and Input.is_action_just_pressed("ui_accept"):
		#bajamos al personaje de plataforma si se encuentra en superficie onewaycollision
		if is_on_onewaycol:
			position = Vector2(position.x,position.y+1)
		elif can_slide:
			_slide()

	#provocar muerte
	if Input.is_action_just_pressed("ui_focus_next") and Input.is_action_pressed("ui_up"):
		death()

	#------- Jump Physics -----------
	#Player is falling
	if velocity.y > 0:
		#Falling action is faster than jumping action | Like in mario
		velocity += Vector2.UP * (-0.5) * (fall_multiplier)
		pass
	#Player is jumping
	#esta fisica solo se aplica durante el primer salto
	elif Input.is_action_just_released('ui_accept') and num_jumps <= 1 and velocity.y <= -120 and state in ["jump","attack"]:
		#Jump Height depends on how long you will hold key
		velocity += Vector2.UP * (-0.5) * (low_jump_multiplier)

func _move():
	#si no hay pulsacion no se moverá o en los siguientes estados
	if direction.x == 0 or state in ["crouch","slide"] or (is_on_floor() and state in ["attack","attack-crouch"]):
		#evitar deslizamiento sobre rampas
		if $Sprite/RayCastRampFront.is_colliding() or $Sprite/RayCastRampBack.is_colliding():
			#para evitar que backdash se trave en rampas
			if state != "backdash" and state != "slide":
				velocity.x = 0
		else:
			velocity.x = lerp(velocity.x, 0, friction)
	#si hay pulsacion
	elif direction.x != 0:
		velocity.x = lerp(velocity.x,direction.x*(speed*run_vel_multiplier),acceleration)

func _throw_health_item():
#	state = "attack"
#	anim_state_machine.start("attack")
	pass		

func _backdash():
	if state != "slide" and state != "attack-crouch" and is_on_floor() and state != "backdash" and state != "crouch" and anim_current != "backdash" and anim_current != "pos-backdash" and can_backdash:
		$TimerBackdash.start()
		$Sprite/XandriaWeapon.cancel()
		Audio.play_voice("xandria-up")
		Audio.play_sfx("backdash")
		change_state("backdash")

func _slide():
	if is_on_floor() and state == "crouch" and anim_current != "attack" and can_slide:
		if anim_current == "backdash":
			return
		$TimerSlide.start()
		Audio.play_sfx("slide")
		change_state("slide")

func _crouch():
	velocity.x = 0
	change_state("crouch")
	
func _jump():
	
	#evitar saltar si se puede deslizar
	#o estamos en plataforma oneway
	if (is_on_floor() and can_slide and Input.is_action_pressed("ui_down")) or state in ["slide","attack","attack-crouch"] or (state == "crouch" and $Sprite/RayCastUp.is_colliding()) or (Input.is_action_pressed("ui_down") and is_on_onewaycol):#or $Sprite/RayCastUp.is_colliding():
		return
		
	if (!can_double_jump and num_jumps == 0) or (can_double_jump and num_jumps <= 1):
		Audio.play_sfx("jump")
		if num_jumps > 0:
			anim_state_machine.start("jump2")

		change_state("jump")
		#para arreglar saltos al moverse en rampa
		velocity.y=0
		#cambiamos a snap normal para poder saltar
		snap_vector = Vector2.ZERO
		#----- Normal Jump action ---------
		#se pone += para evitar reduccion de velocidad al saltar
		velocity += Vector2.UP * jump_velocity
		#le agregamos velocidad del suelo en y para lograr un salto estable mientras la plataforma sube verticalmente
		velocity.y += get_floor_velocity().y
		if is_on_floor():
			num_jumps += 1
		#en caso de haber saltado estando en el aire, agregamos otro salto al contador
		#hacer 2 saltos solo se permite estando en el suelo
		#esto sería como una especie de "tiempo coyote"
		else:
			num_jumps = 2

func _attack():
	if state != "attack" and state != "attack-crouch" and state != "slide" and $TimerAttack.get_time_left() == 0:
		
		if ($Sprite/RayCastUp.is_colliding() or Input.is_action_pressed("ui_down")) and state == "crouch" and anim_current in ["crouch","pos-slide"]:
			change_state("attack-crouch")
		elif state != "crouch":
			change_state("attack")

		$TimerAttack.start()
		
#cambiar entre estados automaticamente
func _check_states():
	
	#al estar heridos en el aire no se podrá cambiar a otro estado automaticamente
	if (state == "hurt" and !is_on_floor()) or state == "dead":
		return
	
	#correccion de volteo de sprites
	#(al atacar y mantener direccion contraria presionada
	if facing != $Sprite.scale.x and state != "attack" and state != "attack-crouch":
		$Sprite.scale.x = facing
	
	#estados que no permiten cambiar automaticamente a otro estado
	if state in ["attack","attack-crouch","crouch","backdash","slide"]:
		if !is_on_floor() and state == "crouch":
			change_state("fall")
		if !is_on_floor() and state == "slide":
			change_state("fall")
		#arreglar animacion de slide al hacerlo muy de seguido
		if state == "slide" and anim_current == "pos-slide":
			anim_state_machine.start("slide")
		#arreglar estado crouch cuando no está presionado abajo y no hay
		#colision con cabeza estando agachado
		if state == "crouch" and !Input.is_action_pressed("ui_down") and !$Sprite/RayCastUp.is_colliding():
			change_state("idle")
	else:
		
		if state == "idle" and anim_current == "hurt":
			change_state("idle")
		
		#corregir estado hurt, manteniendo abajo presionado y tocando el suelo
		if state == "hurt" and Input.is_action_pressed("ui_down") and is_on_floor():
			change_state("idle")
		
		if direction.x == 0 and is_on_floor() and !Input.is_action_pressed("ui_down") and state != "attack" and state != "attack-crouch":
			change_state("idle")
			
		if direction.x != 0 and is_on_floor():
			change_state("run")
	
		if is_on_floor():
			num_jumps = 0
		
		if !is_on_floor() and velocity.y<0 and state!="jump":
			change_state("jump")
		
		if !is_on_floor() and velocity.y>0 and state!="fall":
			change_state("fall")

#variable id del colisionador y posicion del mismo
func hurt(enemy_id=null,hurt_pos=null):
	
	if state == "hurt" or $TimerNoHurt.get_time_left() != 0:
		return
		
	Audio.play_sfx("hit-player")
		
	$Sprite/XandriaWeapon.cancel()	
	
	var damage = 0
	#calculo de daño y mostrarlo
	if enemy_id != null:
		damage = Vars.enemy[enemy_id]["atk"] - Vars.player["def"]
		#evitar valores negativos
		if damage < 0:
			damage = 0
		#establecer daño en hp
		Vars.player["hp_now"] = Functions.get_value(Vars.player["hp_now"],"-",damage)
	
	#emitir señal de daño luego de haberlo calculado
	emit_signal("damaged")
	
	#screen shake
	get_node("PlayerCamera").add_trauma(0.5)
	
	#muerte del jugador el resto del codigo no se ejecutará
	if Vars.player["hp_now"] < 1:
		death()
		emit_signal("dead")
		return
	
	damage_indicator_instance = damage_indicator.instance()
	damage_indicator_instance.set_damage(damage)
	damage_indicator_instance.position = $Sprite/BloodPosition/Pos6.global_position
	get_parent().add_child(damage_indicator_instance)
		
	#dar invencibilidad
	nohurt()

	emit_blood()
	
	#empujamos al jugador en posicion contraria al del enemigo
	velocity.x = 0
	direction.x = 0
	
	if hurt_pos.x > get_position().x:
		facing = 1
		$Sprite.scale.x = 1
		velocity.x += (70 * -1)
	else:
		facing = -1
		$Sprite.scale.x = -1
		velocity.x += (70 * 1)
	
	#la animacion solo será cuando no estemos agachados y tocando techo
	if !$Sprite/RayCastUp.is_colliding():
		change_state("hurt")
		#tomado de _jump()
		velocity.y = 0
		snap_vector = Vector2.ZERO
		velocity += Vector2.UP * 240
	
	#sonido
	var voices = ["xandria-damage1","xandria-damage2","xandria-damage3"]
	var selected_voice = 0
	randomize()
	selected_voice = randi() % 3
	Audio.play_voice(voices[selected_voice])
	
	
func death():
	
	enable_collision_with_danger(false)
	
	Audio.play_voice("xandria-death")
	
	#tomado de hurt()
	$Sprite/XandriaWeapon.cancel()	
	
	anim_state_machine.start("dead")
	state = "dead"
	$Sprite.self_modulate.a = 1
	set_physics_process(false)
	set_process_input(false)
	set_process(false)
	
	var end_pos = position
	end_pos.y -= 50
	$Tween.interpolate_property(self,"position",position,end_pos,5,
	Tween.TRANS_LINEAR,Tween.TRANS_LINEAR)
	$Tween.start()

#activar invencibilidad por x tiempo en segundos
func nohurt(time=1.5):
	$TimerNoHurt.start(time)
	$Sprite.self_modulate.a = .5
	enable_collision_with_danger(false)
	
#funcion para activar o desactivar colissions que hacen daño al jugador
func enable_collision_with_danger(v=true):
	var enemies=get_tree().get_nodes_in_group("enemies")
#	var proyectiles=get_tree().get_nodes_in_group("proyectiles")
	#desactivamos o activamos colision contra enemigos
	#por ejemplo, si el bit (en el editor) es 1, en codigo sera 0
	set_collision_mask_bit(2,v)
	#proyectiles
	for en in enemies:
		if is_instance_valid(en):
			en.set_collision_mask_bit(0,v)
#	for pr in proyectiles:
#		if is_instance_valid(pr):
##			pr.set_collision_mask_bit(7,v)
#			pass

#cambiar estado manualmente
func change_state(new_state):
	
	if state == new_state and new_state != "attack" or (state == "hurt" and !is_on_floor()) or (new_state == "idle" and $Sprite/RayCastUp.is_colliding()):
		return

	state = new_state
	
	if state in ["crouch","slide","attack-crouch"]:
		set_body_collision("crouch")
	else:
		if !$Sprite/RayCastUp.is_colliding():
			set_body_collision()
	
	if state == "jump" and num_jumps > 0:
		pass
	elif state in ["backdash","attack","hurt"]:
		anim_state_machine.start(new_state)
	else:
		#arreglar error al atacar agachado (y que termine el ataque) 
		#y que no esté presionado abajo
		if !Input.is_action_pressed("ui_down") and state in ["crouch"]:
			change_state("idle")
			return
		anim_state_machine.travel(new_state)
		
	#animacion de ataque
	if state in ["attack","attack-crouch"]:
		if Input.is_action_pressed("ui_up") and state == "attack":
			pass
		else:
			$Sprite/XandriaWeapon.attack()

#cambiar cual colision de cuerpo usar	
func set_body_collision(pose="stand"):
	if pose == "stand":
		$Sprite/RayCastUp.enabled = false
		$CollisionStand.disabled = false
		$CollisionCrouch.disabled = true
		#posicion del arma
		$Sprite/XandriaWeapon.position = Vector2(18.501,0.483)
	elif pose == "crouch":
		$Sprite/RayCastUp.enabled = true
		$CollisionStand.disabled = true
		$CollisionCrouch.disabled = false
		#posicion del arma
		$Sprite/XandriaWeapon.position = Vector2(18.491,16.474)

func change_direction(new_dir):
	
	#bajo estas condiciones no se permite cambiar la direccion
	if facing == new_dir:# or (anim_current == "pos-run" and state in ["idle","run"]):
		return
			
	#en los siguientes estados no se puede cambiar direccion
	if state in ["crouch","backdash","slide","attack","attack-crouch"]:
		return
	#si ya estaba animacion de cambiardireccion entonces se reproduce desde inicio
	elif is_on_floor():
		anim_state_machine.start("changedir")

	#se agregó conidcion para evitar mostrar volteado una animacion antes de changedir
	#if anim_current != "pos-run":#or anim_current != "slide":
	$Sprite.scale.x = new_dir

func emit_blood(random=false):
	blood_particle_instance = blood_particle.instance()
	
	if !random:
		if !$Sprite/RayCastUp.is_colliding():
			blood_particle_instance.position = $Sprite/BloodPosition/Pos6.global_position
		else:
			blood_particle_instance.position = $Sprite/BloodPosition/Pos7.global_position
	else:
		#
		randomize()
		var positions = $Sprite/BloodPosition.get_children()
		var selected_pos = randi() % positions.size() 
		blood_particle_instance.position = positions[selected_pos].global_position
	
	get_parent().add_child(blood_particle_instance)
	blood_particle_instance.emit()

#al acabarse el backdash
func _on_TimerBackdash_timeout():
	if state != "hurt" or state != "dead":
		state = "idle"

#al acabarse el slide
func _on_TimerSlide_timeout():
	if state != "hurt" or state != "dead":
		if (Input.is_action_pressed("ui_down") or $Sprite/RayCastUp.is_colliding()) and is_on_floor():
			state = "crouch"
		elif is_on_floor():
			velocity.x = 0
			change_state("idle")

#cuando se termina ataque
func _on_TimerAttack_timeout():
	if state != "hurt" or state != "dead":
		if state in ["attack","attack-crouch"]:
			if (Input.is_action_pressed("ui_down") or $Sprite/RayCastUp.is_colliding()):# and is_on_floor():
				if Input.is_action_pressed("ui_down") and state == "attack-crouch":
					anim_state_machine.start("pos-slide")
				elif Input.is_action_pressed("ui_down") and state == "attack":
					anim_state_machine.start("crouch")
				state = "crouch"
			else:
				#este if para corregir animacion de caer luego de atacar en el aire
				if !is_on_floor() and velocity.y != 0 and state == "attack":
					state = "fall"
					anim_state_machine.start("pos-jump")
				else:
					change_state("idle")

#se acaba el tiempo de invisibilidad
func _on_TimerNoHurt_timeout():
	$Sprite.self_modulate.a = 1
	enable_collision_with_danger()
