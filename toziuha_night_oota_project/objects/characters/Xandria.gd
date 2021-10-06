extends KinematicBody2D

signal dead
signal damaged
# warning-ignore:unused_signal
signal stats_changed

signal absorb_circuit_started
signal absorb_circuit_canceled

var weapon_textures = [
	preload("res://assets/sprites/xandria_chain_whip_lvl1.png"),
	preload("res://assets/sprites/xandria_chain_whip_lvl2.png"),
	preload("res://assets/sprites/xandria_chain_whip_lvl3.png"),
]

var blood_particle = preload("res://objects/particles/BloodParticle.tscn")
var blood_particle_instance = null

const FLOOR_NORMAL = Vector2.UP
const SNAP_DIRECTION = Vector2.DOWN
const SNAP_LENGTH = 10#32.0 #se cambio a 10, para evitar que al caer de una baja altura, el cuerpo se pegue inmediatamente al suelo
#el limite de grados en el que un objeto es considerado suelo
#despues de 45 será pared...
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
#gravedad cuando se está atacando, esta debe ser un poco menor
var gravity_attack = 100#500
#velocidad para desplazamiento
export var speed = 110

#cantidad de saltos realizados
var num_jumps = 0

export var acceleration = 0.1
export var friction = 0.2

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
export(int,-1,1) var facing = 1

var was_on_floor = true

#el jugador está en una plataforma semisolida?
var is_on_onewaycol = false

#mientras sea true la funcion throw_subweapon spawneará subarma
var can_throw = false

#al ser false, el jugador no podrá moverse
var can_move = true

#si el jugador se está balanceando desde el latigo
#la gravedad se desactiva
var whip_swing = false

#limites de camara
export var limit_left_camera = -10000000
export var limit_top_camera = -10000000
export var limit_right_camera = 10000000
export var limit_bottom_camera = 10000000

#ultimo input presionado
var last_action = "ui_up"

func _ready():
	
	#quitar cualquier colision del latigo hasta que se active con botón
	weapon_cancel()
	
	#colocar textura del latigo de acuerdo a nivel
	weapon_change_level(Vars.player["weapon_lvl"])
	
	#establecer hacia qué lado mira el jugador
	if Vars.player_facing != 0:
		facing = Vars.player_facing
	
	#colocar limites de camara al nodo camera
	$PlayerCamera.limit_left = limit_left_camera
	$PlayerCamera.limit_top = limit_top_camera
	$PlayerCamera.limit_right = limit_right_camera
	$PlayerCamera.limit_bottom = limit_bottom_camera
	
	#colision del cuerpo normal (no agachado)
	set_body_collision()
	
	anim_state_machine = $AnimationTree.get("parameters/playback")
	anim_current = anim_state_machine.get_current_node()
	
	# warning-ignore:return_value_discarded
	Timers.get_node("AutomaticChangeToGoodCondition").connect("timeout",self,"_return_to_good_condition")
	# warning-ignore:return_value_discarded
	Timers.get_node("TimerHeal").connect("timeout",self,"_on_TimerHeal_timeout")
	# warning-ignore:return_value_discarded
	Timers.get_node("TimerHealingEnd").connect("timeout",self,"_on_TimerHealingEnd_timeout")
	# warning-ignore:return_value_discarded
	Timers.get_node("TimerRecoverStamina").connect("timeout",self,"_on_TimerRecoverStamina_timeout")


#debug
func _process(_delta):
	ScreenDebugger.dict["State"] = state
	ScreenDebugger.dict["Anim"] = str( anim_current )
#	ScreenDebugger.dict["Jumps"] = str( num_jumps )
#	ScreenDebugger.dict["Vel_X"] = str( round(velocity.x) )
#	ScreenDebugger.dict["Vel_Y"] = str( round(velocity.y) )
#	ScreenDebugger.dict["Dir_X"] = str( round(direction.x) )
#	ScreenDebugger.dict["Facing"] = str( facing )
#	ScreenDebugger.dict["Scale_X"] = str( $Sprite.scale.x )
#	ScreenDebugger.dict["OnFloor"] = str( is_on_floor() )
#	ScreenDebugger.dict["OnWall"] = str( is_on_wall() )
#	ScreenDebugger.dict["RyCstUp"] = str( $Sprite/RayCastUp.is_colliding() )
#	ScreenDebugger.dict["onewaycol"] = str( is_on_onewaycol )
	


func _physics_process(delta):
	
	if is_on_floor() and (get_floor_velocity().x!=0 or get_floor_velocity().y!=0):
		stop_on_slope = false
	else:
		stop_on_slope = true
	
	was_on_floor = is_on_floor()
	
	anim_current = anim_state_machine.get_current_node()
	
	#se cambiará la direccion solo si no está la animacion changedir en reproduccion
	if direction.x != 0 and state != "backdash" and state != "dodge" and state != "attack" and state != "attack-crouch" and anim_current != "slide" and anim_current != "throw":
		change_direction(direction.x)
		facing = direction.x
	
	if state != "hurt":
		_get_input()
	
	#gravedad
	if velocity.y > 70 and !whip_swing and anim_current in ["attack","attack-diag-up","attack-down","attack-diag-down"]:
		#print(velocity.y)
		velocity.y += gravity_attack*delta
	elif !whip_swing:
		velocity.y += gravity*delta
	else:
		velocity.y = 0

	#movimiento automatico en backdash
	if state == "backdash" and is_on_floor():
		velocity.x = -170 * facing
	
	#movimiento automatico para doge (lo contrario a backdash)
	if state == "dodge" and is_on_floor():
		velocity.x = 150 * facing
			
	#y movimiento para slide
	if state == "slide" and is_on_floor():
		velocity.x = 170 * facing

	#movimiento general en Y
	velocity.y = move_and_slide_with_snap(velocity,snap_vector,FLOOR_NORMAL,stop_on_slope,4,SLOPE_THRESHOLD).y
		
	_check_states()
	
	#comprobar en cada frame si tocamos suelo por primera vez
	#(luego de haber estado en el aire
	if is_on_floor() and !was_on_floor:
#		if Vars.joy_vibrate:
#			print(abs(velocity.y))
#			Input.start_joy_vibration(0,0.1,0.2,0.2)
		Audio.play_sfx("foot_floor")
		
	#-------------- deteccion de colisiones con enemigos o plataformas ----------------------
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		
		#detectar colision oneway
#		if collision.collider is TileMap:
#			var tile_pos = collision.collider.world_to_map(position)
#			tile_pos -= collision.normal
#			var tile_id = collision.collider.get_cellv(tile_pos)
#			print(str(tile_id))
#			if tile_id >= 0:
#				var tile_name = collision.collider.tile_set.tile_get_name(tile_id)
#				#si estamos sobre un tile con onewaycolision
#				is_on_onewaycol = collision.collider.tile_set.tile_get_shape_one_way(tile_id,0)
		
		if collision.collider.is_in_group("semisolid"):
			is_on_onewaycol = true
		else:
			is_on_onewaycol = false
		
#		if collision.collider.is_in_group("enemies"):
#			var cpos = collision.collider.get_position()
#			hurt(collision.collider.id,cpos)
#
#		if collision.collider.is_in_group("poison"):
#			change_condition("poison")


func _get_input():
	
	if !can_move or state == "dodge":
		return
	
	#mientras haya un dialogo activo se detiene movimiento
	if DialogBox.active:
		direction.x = 0
		velocity.x = 0
		return
		
	#detectar un doble input del dpad
#	if Input.is_action_just_pressed(last_action) and $TimerInput.get_time_left() != 0:
#		match last_action:
#			#abrir menú de equipamiento rapido (para elementos y circuitos)
#			"ui_up":
#				get_tree().get_nodes_in_group("hud")[0].get_node("ControlQuickEquip").show_menu()
#		#limpiar la ultima accion
#		last_action = "none"
#		#ejecutar dodge
#		_dodge()
#	if Input.is_action_just_pressed("ui_left"):
#		last_action = "ui_left"
#		$TimerInput.start()
#	elif Input.is_action_just_pressed("ui_right"):
#		last_action = "ui_right"
#		$TimerInput.start()
#	if Input.is_action_just_pressed("ui_up"):
#		last_action = "ui_up"
#		$TimerInput.start()
		
	
	#movimiento con teclas siempre y cuando no estemos heridos
	
	# --------- detectar entrada de tecla izq o der para movimiento horizontal ----------
#	direction.x = int( Input.is_action_pressed('ui_right') ) - int( Input.is_action_pressed('ui_left') )
	#metodo alternativo
	if Input.is_action_pressed("ui_left") and state != "backdash" and state != "dodge" and state != "slide" and state != "charging":
		direction.x = -1
	elif Input.is_action_pressed("ui_right") and state != "backdash" and state != "dodge" and state != "slide" and state != "charging":
		direction.x = 1
	else:
		direction.x = 0

	_move()
	
	#iniciar estado de carga para obtener circuito elemental
	#izq y der no debe estar presionado
	if Input.is_action_just_pressed("ui_up") and (!Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right")) and is_on_floor() and state != "crouch" and state != "attack" and state != "attack-crouch":
		$TimerStartCharging.start()
	elif Input.is_action_just_released("ui_up"):
		$TimerStartCharging.stop()
		if state == "charging":
			change_state("idle")

	#desactivar ataque circular al soltar botón ataque
	if anim_current == "attack-circle" and Input.is_action_just_released("ui_cancel"):
		
		change_state("idle")
	
	#agacharse
	if Input.is_action_pressed("ui_down") and is_on_floor() and state != "slide" and state != "attack-crouch" and state != "attack":
		#al terminar de deslizarse no se detendrá movimiento en X en seco (ver _crouch())
		if velocity.x != 0 and anim_current == "slide":
			_crouch(false)
		else:
			_crouch()
	#levantarse (si la cabeza no toca techo)
	elif Input.is_action_just_released("ui_down") and state == "crouch" and !$Sprite/RayCastUp.is_colliding():
		change_state("idle")
		
	#acción de ataque	
	if Input.is_action_just_pressed("ui_cancel"):
		$TimerBtnAttackPress.start()
		_attack()
		
	#accion para usar un item curativo
	if Input.is_action_pressed("ui_down") and Input.is_action_just_pressed("ui_focus_next"):
		_use_health_item()
		
	#accion para lanzar subarma
	if !Input.is_action_pressed("ui_down") and !$Sprite/RayCastUp.is_colliding() and Input.is_action_just_pressed("ui_focus_next") and state != "attack-crouch" and state != "crouch" and state != "charging":
		_throw_subweapon()
		
	#salto
	if Input.is_action_just_pressed("ui_accept"):
		_jump()
	else:
		#si no pulsamos btn salto, hay snap para pegar al jugador al suelo inclinado
		snap_vector = SNAP_DIRECTION * SNAP_LENGTH

		
	#esquivar hacia adelante
	if is_on_floor() and Input.is_action_just_pressed("ui_focus_prev") and (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")) and Vars.player["hability_dodge"]:
		_dodge()
	# esquive hacia atrás (backdash)
	elif Input.is_action_just_pressed("ui_focus_prev") and is_on_floor():
		_backdash()
		
	#slide
	if is_on_floor() and Input.is_action_pressed("ui_down") and Input.is_action_just_pressed("ui_accept"):
		#bajamos al personaje de plataforma si se encuentra en superficie onewaycollision
		if is_on_onewaycol:
			position = Vector2(position.x,position.y+1)
		elif Vars.player["hability_slide"]:
			_slide()

	#------- Jump Physics -----------
	#Player is falling
	if velocity.y > 0:
		#Falling action is faster than jumping action | Like in mario
		velocity += Vector2.UP * (-0.5) * (fall_multiplier)
		pass
	#Player is jumping
	#esta fisica solo se aplica durante el primer salto
#	elif Input.is_action_just_released('ui_accept') and num_jumps <= 1 and velocity.y <= -120 and state in ["jump","attack"]:
	elif Input.is_action_just_released('ui_accept') and num_jumps <= 1 and abs(velocity.y) > 80 and state in ["jump","attack"]:
		#print(abs(velocity.y))
		#Jump Height depends on how long you will hold key
		velocity += Vector2.UP * (-0.5) * (low_jump_multiplier)

func _move():
	#si no hay pulsacion no se moverá o en los siguientes estados
	if direction.x == 0 or state in ["crouch","slide"] or (is_on_floor() and state in ["attack","attack-crouch","charging"] or (anim_current=="throw" and is_on_floor())):
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

func _use_health_item():
	#si no tenemos la vida llena, con al menos una pocion y no nos estamos curando
	if Vars.player["hp_now"] < Vars.player["hp_max"] and Vars.player["potion_now"] > 0 and Vars.player["condition"] != "healing":
		Vars.player["condition"] = "healing"
		Audio.play_sfx("potion_use")
		Vars.player["potion_now"] = Functions.get_value(Vars.player["potion_now"],"-",1)
		$PotionUse/AnimationPlayer.play("show")
		#iniciar timers
		Timers.get_node("TimerHeal").start()
		Timers.get_node("TimerHealingEnd").start()
		emit_signal("stats_changed")
	#con la vida llena y con al menos una pocion
	elif Vars.player["hp_now"] == Vars.player["hp_max"] and Vars.player["potion_now"] > 0:
		Audio.play_sfx("btn_incorrect")
		show_quick_notif("HEALTHFULL")
	#sin pociones
	elif Vars.player["potion_now"] == 0:
		Audio.play_sfx("btn_incorrect")
		show_quick_notif("NOTPOTIONS")

func _backdash():
	if Vars.player["sp_now"] > 20 and state != "slide" and state != "attack-crouch" and is_on_floor() and state != "backdash" and state != "crouch" and anim_current != "backdash" and anim_current != "pos-backdash":

		decrease_stamina(20)
		
		$TimerBackdash.start()
		weapon_cancel()
		Audio.play_voice("xandria-up")
		Audio.play_sfx("backdash")
		change_state("backdash")

func _dodge():
	if Vars.player["sp_now"] >= 30 and state != "slide" and state != "attack-crouch" and is_on_floor() and state != "dodge" and state != "crouch" and anim_current != "dodge":# and Vars.player["hability_dodge"]:
		
		decrease_stamina(30)
		
		$TimerBackdash.start()
		weapon_cancel()
		Audio.play_voice("xandria-up")
		Audio.play_sfx("backdash")
		change_state("dodge")
		nohurt(0.5,false)

func _slide():
	if is_on_floor() and state == "crouch" and anim_current != "attack" and anim_current in ["crouch","pos-slide"] and Vars.player["hability_slide"]:
		if anim_current in ["backdash","dodge"]:
			return
		$TimerSlide.start()
		Audio.play_sfx("slide")
		change_state("slide")

func _crouch(stop_x_move=true):
	#detener movimiento de X en seco
	#dejar en false para que el propio lerp de _move haga su trabajo
	if stop_x_move:
		velocity.x = 0
	change_state("crouch")
	
func _jump():
	
	#evitar saltar si se puede deslizar
	#o estamos en plataforma oneway
	if (is_on_floor() and Vars.player["hability_slide"] and Input.is_action_pressed("ui_down")) or state in ["slide","attack","attack-crouch"] or (state == "crouch" and $Sprite/RayCastUp.is_colliding()) or (Input.is_action_pressed("ui_down") and is_on_onewaycol):#or $Sprite/RayCastUp.is_colliding():
		return
		
	if (!Vars.player["hability_double_jump"] and num_jumps == 0) or (Vars.player["hability_double_jump"] and num_jumps <= 1):
		
		if num_jumps > 0:
			anim_state_machine.start("jump2")
			Audio.play_sfx("jump2")
		else:
			Audio.play_sfx("jump")

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
#	if state != "attack" and state != "attack-crouch" and state != "slide" and $TimerAttack.get_time_left() == 0:
	if $TimerAttack.get_time_left() < 0.09 and state != "slide":
		
		if is_on_floor() and (Input.is_action_pressed("ui_down") or state in ["attack-crouch","crouch"]):
			change_state("attack-crouch")
		elif state != "crouch":
			change_state("attack")

		$TimerAttack.start(0.56) #duracion de la animacion
		weapon_attack()

func _throw_subweapon():
	#si solo se mantiene presionado arriba y no las otras direcciones quiere decir que se lanzará subarma por lo que se oculta el latigo
	#ya que se reutiliza la animación para lanzar subarmas
	#siempre y cuando se tenga subarma, y maná suficiente para tirarlo
	if anim_current != "throw" and Vars.player["subweapon"] != "none" and Vars.player["mp_now"] >= Vars.subweapons[Vars.player["subweapon"]]["mp_use"]:
		can_throw = true #usado para throw_subweapon que se llama desde animationplayer
		change_state("throw")

#cambiar textura del latigo dependiendo de nivel
func weapon_change_level(lvl=1):
	$Sprite/Weapon/ChainWhip.texture = weapon_textures [lvl-1]
	weapon_enable_collision(lvl)

#reproducir sonido de arma y además activar o desactivar las colisiones necesarias
func weapon_attack():
	
	#cancelar tirar subarma
	can_throw = false
	
	#randomizar cual voz usar para el ataque
	randomize()
	var voices = ["xandria-attack1","xandria-attack2","xandria-attackfast",null,null,null]
	var selected_voice = randi() % 6
	if voices[selected_voice] != null:
		Audio.play_voice(voices[selected_voice])

	weapon_enable_collision(Vars.player["weapon_lvl"])

	weapon_sound_woosh()
	Audio.play_sfx("chains")

#sonido woosh del latigo
func weapon_sound_woosh(normal=true):
	if normal:
		Audio.play_sfx("whip_woosh")
	else:
		Audio.play_sfx("whip_woosh_light")
	
#activar la colision del arma especificada (las demás se desactivan)
func weapon_enable_collision(lvl=0):
	#desactivar todas las colisiones (y ocultarlas para propositos de testeo
	
	$Sprite/Weapon/AreaFootSlide.monitoring = false
	$Sprite/Weapon/AreaFootSlide.visible = false
	
	#si no se especifica se oculta el sprite del arma y se deja desactivada todas las colisiones con el bloque de codigo anterior
	if lvl == 0:
		$Sprite/Weapon/ChainWhip.visible = false
	else:
		if lvl < 2:
			lvl = 2
		$Sprite/Weapon/ChainWhip.visible = true
	
	#desactivar colisiones y dejar en true area del nivel de arma actual
	for w_lvl in [2,3]:
		get_node("Sprite/Weapon/AreaLvl%d/CollisionPolygon2D"%[w_lvl]).polygon = []
		if w_lvl == lvl:
			get_node("Sprite/Weapon/AreaLvl%d"%[w_lvl]).monitoring = true
			get_node("Sprite/Weapon/AreaLvl%d"%[w_lvl]).visible = true
		else:
			get_node("Sprite/Weapon/AreaLvl%d"%[w_lvl]).monitoring = false
			get_node("Sprite/Weapon/AreaLvl%d"%[w_lvl]).visible = false
	
#activar o desactivar area de latigo segun el nivel
#para usarse en attack-circle
#gasta estamina
func circle_whip_area_enable(enable=true):
	$Sprite/Weapon/AreaCircle.set_deferred("monitoring",enable)
	$Sprite/Weapon/AreaCircle.set_deferred("visible",enable)

#quitar frames y desactivar colisiones del arma
func weapon_cancel():
	$Sprite/Weapon/PosImpact/WhipLevel3Blood.stop_emit()
	weapon_enable_collision()
	$Sprite/Weapon/ChainWhip.frame = 0
	circle_whip_area_enable(false)
	charge_circuit_cancel()

func charge_circuit_cancel():
	if state == "charging":
		Audio.stop_sfx("precharge_elemental_circuit")
		emit_signal("absorb_circuit_canceled")

func decrease_stamina(val=30):
	Vars.player["sp_now"] = Functions.get_value(Vars.player["sp_now"],"-",val)
	emit_signal("stats_changed")
	#iniciar timers
	Timers.get_node("TimerRecoverStamina").start()
	emit_signal("stats_changed")

	
#cambiar entre estados automaticamente
func _check_states():
	
	#evitar que sonido de cargar circuito siga reproduciendo sin estar cargando
	if Audio.get_node("sfx/precharge_elemental_circuit").is_playing() and state != "charging":
		Audio.get_node("sfx/precharge_elemental_circuit").stop()
	
	#corregir animacion de latigo de cadenas si no se está atacando
	if !anim_current.begins_with("attack") and $Sprite/Weapon/ChainWhip.frame != 0:
		$Sprite/Weapon/ChainWhip.frame = 0
	
	#corregir animacion de herirse
	if state == "hurt" and anim_current != "hurt":
		anim_state_machine.start("hurt")
	
	#al estar heridos en el aire no se podrá cambiar a otro estado automaticamente
	if (state == "hurt" and !is_on_floor()) or state == "dead":
		return
	
	#correccion de volteo de sprites
	#(al atacar y mantener direccion contraria presionada
	if facing != $Sprite.scale.x and state != "attack" and state != "attack-crouch" and anim_current != "slide":
		$Sprite.scale.x = facing
	
	#estados que no permiten cambiar automaticamente a otro estado
	if state in ["attack","attack-crouch","crouch","backdash","dodge","dash","slide","charging"]:
		if !is_on_floor() and state == "crouch":
			change_state("fall")
		if !is_on_floor() and state == "slide":
			change_state("fall")
		#cancelar animacion ataque hacia abajo estando en el suelo
		if is_on_floor() and anim_current in ["attack-down","attack-diag-down"]:
			change_state("idle")
			anim_state_machine.start("idle")
		#arreglar animacion de slide al hacerlo muy de seguido
		if state == "slide" and anim_current == "pos-slide":
			anim_state_machine.start("slide")
		#arreglar estado crouch cuando no está presionado abajo y no hay
		#colision con cabeza estando agachado
		if state == "crouch" and !Input.is_action_pressed("ui_down") and !$Sprite/RayCastUp.is_colliding():
			change_state("idle")
		#cancelar carga si por alguna razón sigue la animacion activa a pesar de no tener presionado "arriba"
		if state == "charging" and is_on_floor() and !Input.is_action_pressed("ui_up"):
			change_state("idle")
	else:
		
		if state == "idle" and anim_current == "hurt":
			change_state("idle")
			
		if state == "idle" and anim_current == "jump" and is_on_floor():
			anim_state_machine.start("idle")
		
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
		
		if !is_on_floor() and velocity.y>0 and state!="fall" and state != "throw":
			change_state("fall")
		
		#arreglar de que animacion de carga se quede a pesar de no estar presionando arriba
		if state == "idle" and anim_current == "charging" and !Input.is_action_pressed("ui_up"):
			anim_state_machine.travel("idle")
			#weapon_cancel()
		
		#corregir animacion de attack circle aun con el boton sin presionar
		if state == "idle" and anim_current == "attack-circle" and !Input.is_action_pressed("ui_cancel"):
			
			change_state("idle")

#variable id del colisionador y posicion del mismo
func hurt(enemy_danger):
	
	if state == "hurt" or $TimerNoHurt.get_time_left() != 0:
		return
		
	
		
	Audio.play_sfx("hit-player")
		
	weapon_cancel()
	
	Input.action_release("ui_cancel")
	
	#soltar a xandria del punto de apoyo para balancearse
	#en caso de estar enganchada a uno
	for a in get_tree().get_nodes_in_group("chain_swing"):
		a.chain_release()
	
	var damage = 0
	
	#calculo de daño y mostrarlo
	if enemy_danger != null:
		damage = enemy_danger.cE.atk - Vars.player["def"]
		#evitar valores negativos
		if damage <= 0:
			damage = 5 #minimo de daño a recibir
		#establecer daño en hp
		Vars.player["hp_now"] = Functions.get_value(Vars.player["hp_now"],"-",damage)

	#emitir señal de daño luego de haberlo calculado
	emit_signal("damaged")
	
	#screen shake
	get_node("PlayerCamera").add_trauma(0.45)
	
	#vibracion de control
	if Vars.joy_vibrate:
		Input.start_joy_vibration(0,0.2,0.3,0.7)
	
	#muerte del jugador el resto del codigo no se ejecutará
	if Vars.player["hp_now"] < 1:
		if Vars.joy_vibrate:
			Input.start_joy_vibration(0,0.2,0.9,1)
		death()
		return

	Functions.show_damage_indicator(damage,$Sprite/BloodPosition/Pos6.global_position,"black")
		
	#dar invencibilidad
	nohurt()

	emit_blood()
	
	#empujamos al jugador en posicion contraria al del enemigo
	velocity.x = 0
	direction.x = 0
	
	#knockback
	if enemy_danger.global_position.x > get_position().x:
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
	
	Vars.player["hp_now"] = 0
	
	emit_signal("dead")
	enable_collision_with_danger(false)
	
	Audio.play_voice("xandria-death")
	
	#tomado de hurt()
	weapon_cancel()
	
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
func nohurt(time=1.5,change_alpha=true):
	$TimerNoHurt.start(time)
	if change_alpha:
		$Sprite.self_modulate.a = .5
	enable_collision_with_danger(false)
	
#funcion para activar o desactivar el hitbox
func enable_collision_with_danger(v=true):
	$HitBox.set_deferred("monitoring",v)

#cambiar estado manualmente
func change_state(new_state):
	
	#evitar que se cambie a idle mientras estamos en slide
	if new_state == "idle" and state == "dead":
		return
	#
	if (state == new_state and state != "attack-crouch") and new_state != "attack"  or (state == "hurt" and !is_on_floor()) or (new_state == "idle" and $Sprite/RayCastUp.is_colliding()):
		return
	
	#quitar healing en los siguientes estados
	if Vars.player["condition"] == "healing" and state in ["hurt"]:
		_on_TimerHealingEnd_timeout()
		
	weapon_cancel()
	
	#al atacar muy rapido agachado, se puede dar el caso de que al atacar se siga agachado a pesar de no mantener el boton de abajo
	if new_state == "attack-crouch" and !Input.is_action_pressed("ui_down") and !$Sprite/RayCastUp.is_colliding():
		new_state = "attack"
		
	state = new_state

	#setear colisiones
	if state in ["slide"]:
		set_body_collision("slide")
	elif state in ["crouch","attack-crouch"]:
		set_body_collision("crouch")
	else:
		if !$Sprite/RayCastUp.is_colliding():
			set_body_collision()
	
	if state == "jump" and num_jumps > 0:
		pass
	elif state in ["throw","backdash","dodge","attack","attack-crouch","hurt","dead"]:
		if Vars.player["weapon_lvl"] > 1 and state == "attack" and Input.is_action_pressed("ui_up") and (!Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right")):
			anim_state_machine.start("attack-up")
		elif Vars.player["weapon_lvl"] > 1 and state == "attack" and Input.is_action_pressed("ui_up") and (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
			anim_state_machine.start("attack-diag")
		elif Vars.player["weapon_lvl"] > 1 and state == "attack" and !is_on_floor() and Input.is_action_pressed("ui_down") and !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
			anim_state_machine.start("attack-down")
		elif Vars.player["weapon_lvl"] > 1 and state == "attack" and !is_on_floor() and Input.is_action_pressed("ui_down") and ( Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") ):
			anim_state_machine.start("attack-diag-down")
		elif state == "throw" and is_on_floor():
			state = "attack"
			anim_state_machine.start("throw")
		else:
			anim_state_machine.start(new_state)
	else:
		#arreglar error al atacar agachado (y que termine el ataque) 
		#y que no esté presionado abajo
		if !Input.is_action_pressed("ui_down") and state in ["crouch"]:
			change_state("idle")
			return
		anim_state_machine.travel(new_state)

#cambiar cual colision de cuerpo usar	
#se ha cambiado la forma de hacer diferentes colisiones
#ahora se cambia las propiedades del shape de la colision principal
#en un nodo animationplayer aparte
func set_body_collision(pose="stand"):
	if pose == "stand":
		$Sprite/RayCastUp.enabled = false
		$AnimationPlayerCollision.play("stand")
	elif pose == "crouch":
		$Sprite/RayCastUp.enabled = true
		$AnimationPlayerCollision.play("crouch")
	elif pose == "slide":
		$Sprite/RayCastUp.enabled = true
		$AnimationPlayerCollision.play("slide")

func change_direction(new_dir):
	#bajo estas condiciones no se permite cambiar la direccion
	if (
		facing == new_dir 
		or state in ["crouch","backdash","dodge","slide","attack","attack-crouch"]
		or anim_current == "throw"
	):
		return	
	#si ya estaba animacion de cambiardireccion entonces se reproduce desde inicio
	elif is_on_floor():
		anim_state_machine.start("changedir")

	#se agregó conidcion para evitar mostrar volteado una animacion antes de changedir
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

func change_condition(new_condition="good"):
	if new_condition in ["poison","cursed"]:
		Timers.get_node("AutomaticChangeToGoodCondition").start()
	Vars.player["condition"] = new_condition
	emit_signal("stats_changed")

#al acabarse el backdash
func _on_TimerBackdash_timeout():
	if state != "hurt" or state != "dead":
		state = "idle"

#al acabarse el slide
func _on_TimerSlide_timeout():
	if state != "hurt" or state != "dead":
		if (Input.is_action_pressed("ui_down") or $Sprite/RayCastUp.is_colliding()) and is_on_floor():
			state = "crouch"
			set_body_collision("crouch")
		elif is_on_floor():
#			velocity.x = 0
			change_state("idle")

#cuando se termina ataque
func _on_TimerAttack_timeout():
	if state != "hurt" or state != "dead":
		if state in ["idle","attack","attack-crouch"]:
			#activar ataque circular (usando timer para medir tiempo desde que se mantuvo presionado
			if Vars.player["hability_circle_whip"] and state in ["attack","idle"] and Input.is_action_pressed("ui_cancel") and $TimerBtnAttackPress.get_time_left() <= 0.4 and $Sprite/Weapon/ChainWhip.visible:
#				print(str($TimerBtnAttackPress.get_time_left()))
				anim_state_machine.start("attack-circle")
				circle_whip_area_enable(true)
			#animacion de reposo luego de atacar agachado y mantenerse agachado
			elif (Input.is_action_pressed("ui_down") or $Sprite/RayCastUp.is_colliding()) and is_on_floor():
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

#spawnear subarma desde animacion
#nota: codigo relacionado en el final de change_state()
func throw_subweapon():
	if can_throw :
		$TimerAttack.start(0.4)
		#descontar uso de subarma al maná
		Vars.player["mp_now"] = Functions.get_value(Vars.player["mp_now"],"-",Vars.subweapons[Vars.player["subweapon"]]["mp_use"])
		emit_signal("stats_changed")
		var lvl_base = Functions.get_main_level_scene()
		var subweapon_instance = null
		match Vars.player["subweapon"]:
			"shuriken":
				subweapon_instance = Functions.shuriken_weapon.instance()
				subweapon_instance.direction = facing
			"axe":
				subweapon_instance = Functions.axe_weapon.instance()
				subweapon_instance.direction = facing
		#posicion de spawneo
		subweapon_instance.position = $Sprite/SubWeaponPosition.global_position
		if lvl_base != null:
			lvl_base.call_deferred("add_child",subweapon_instance)

#mostrar una pequeña notificacion encima del jugador
func show_quick_notif(txt=""):
	$QuickNotif/Label.text = txt
	$QuickNotif/AnimationPlayer.stop(true)
	$QuickNotif/AnimationPlayer.play("show_quick_notif")


#se acaba el tiempo de invencibilidad
func _on_TimerNoHurt_timeout():
	$Sprite.self_modulate.a = 1
	enable_collision_with_danger()


#curar de poco a poco
func _on_TimerHeal_timeout():
	Vars.player["potion_healing_hp"] = int(Vars.player["hp_max"]/20)
	var hp_recover = Vars.player["potion_healing_hp"]
	if state == "crouch":
		hp_recover = hp_recover * 2
	Vars.player["hp_now"] += hp_recover
	Functions.show_damage_indicator(hp_recover,$Sprite/BloodPosition/Pos6.global_position,"blue")
	#eliminar excedente
	if Vars.player["hp_now"] > Vars.player["hp_max"]:
		Vars.player["hp_now"] = Vars.player["hp_max"]
	#si se ha llegado el tope de hp max
	if (Vars.player["hp_now"] == Vars.player["hp_max"]) or state in ["hurt","dead"]:
		_on_TimerHealingEnd_timeout()
	#enviar señal para actualizar hud
	emit_signal("stats_changed")
	
func _on_TimerHealingEnd_timeout():
	Vars.player["condition"] = "good"
	Timers.get_node("TimerHeal").stop()
	emit_signal("stats_changed")

#recuperar stamina de a poco
func _on_TimerRecoverStamina_timeout():
	var sp_recover = 5
	if Vars.player["sp_now"] < Vars.player["sp_max"]:
		#al estar agachados recuperamos mas sp
		if state == "crouch":
			sp_recover = sp_recover*2
		Vars.player["sp_now"] += sp_recover
	#eliminar excedente
	if Vars.player["sp_now"] > Vars.player["sp_max"]:
		Vars.player["sp_now"] = Vars.player["sp_max"]
	#si se ha llegado el tope de sp max
	if Vars.player["sp_now"] == Vars.player["sp_max"]:
		Timers.get_node("TimerRecoverStamina").stop()
	#enviar señal para actualizar hud
	emit_signal("stats_changed")

#pasado un tiempo luego de estar poison o cursed se regresará a good
func _return_to_good_condition():
	if Vars.player["condition"] in ["poison","cursed"]:
		Vars.player["condition"] = "good"
		emit_signal("stats_changed")


func _on_Xandria_tree_exiting():
	#antes de salir del escenario, guardar
	#hacia qué lado estaba viendo
	Vars.player_facing = facing


#to do: eliminar funcion
#cuando un area u objeto entra al area del arma que ataca
func _on_WeaponArea_body_entered(_body_area):
	pass

#iniciar carga de magia (o recoger circuito elemental)
func _on_TimerStartCharging_timeout():
	if Input.is_action_pressed("ui_up") and is_on_floor() and state != "crouch" and state != "attack" and state != "attack-crouch":
		Audio.play_sfx("precharge_elemental_circuit",true)
		change_state("charging")
		emit_signal("absorb_circuit_started")
		

#jugador toca algo que le hace daño (enemigos, trampas)
func _on_HitBox_activated(body_area):
	var obj = body_area
	if obj.is_in_group("enemies"):
		if body_area.cE.hp_now > 0:
			hurt(body_area)
			if obj.is_in_group("poison"):
				change_condition("poison")
