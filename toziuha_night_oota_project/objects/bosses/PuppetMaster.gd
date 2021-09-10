extends KinematicBody2D

export (NodePath) var player
export (NodePath) var invoke_object

var cE = load("res://scripts/enemy.gd").new()

#var id = "puppet_master"

#var hp_max = Vars.enemy[id]["hp_max"]
#var hp_now = hp_max

var anim_state_machine

var final_boss = false

#var facing = -1
#var state = "idle"

var chasing = false
var chase_duration = 1

#cuantos golpes ha recibido
var received_hits = 0

var center_position_room = Vector2(0,0)

func _ready():
	
	cE.set_vars("puppet_master")
	
	center_position_room = $PositionCenter.global_position
	
#	Enemy.connect("collision_with_player",self,"_on_collision_with_player")
	anim_state_machine = $AnimationTree.get("parameters/playback")
	
	#desactivar todo y poner invisible el boss
	modulate = Color(1,1,1,0)
	$AnimationTree.active = false
	enabled_collisions(false)
	
	

func change_state(new_state):
	if new_state != cE.state and cE.state != "dead":
		cE.state = new_state
		anim_state_machine.travel(cE.state)
		if cE.state == "fly":
			start_chase()

#que el boss aparezca 
func show_body():
	$Sprite.frame = 11 #frame de muerto
	Audio.play_music("prepare_for_war",false)
	$Tween.interpolate_property(self,"modulate",Color(1,1,1,0),Color(1,1,1,1),3)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	Audio.play_sfx("zombie_roar3")
	$AnimationTree.active = true
	$Timer.start(2)
	yield($Timer,"timeout")
	start_battle()

#listo para pelear
func start_battle():
	change_state("fly")
	enabled_collisions(true)
	Functions.get_main_level_scene().get_node("Hud").set_boss_bar_max(Vars.enemy[cE.id]["hp_max"])
	Functions.get_main_level_scene().get_node("Hud").set_boss_bar_visible()
	start_chase()
	
#animacion de muerte terminó
func end_battle():
	#$AnimationTree.active = false #para evitar repetir animacion... bug creo
	#$Tween.stop_all()
	Audio.play_sfx("enemy_die1")
	$Tween.interpolate_property(self,"modulate",Color(1,1,1,1),Color(1,1,1,0),2)
	$Tween.start()
	$Timer.start(2.5)
	yield($Timer,"timeout")
	cE.open_doors_on_boss_death(self)
	cE.add_boss_orb(center_position_room,self)
	queue_free()

func get_target_position(targetnode=null):
	randomize()
	var opt = randi() % 4
	var decrease_y = [20,80,30,5]
	decrease_y.shuffle()
	var target_pos = targetnode.position
	target_pos.y -= decrease_y[opt]
	return target_pos

func start_chase():
	if cE.state != "dead" and modulate.a == 1:
		
		$Tween.stop_all()
		randomize()
		chase_duration = randi() % 3 + 1
		
		cE.update_facing(self,$Sprite)
		chasing = true
		$Tween.interpolate_property(self, "position", position, get_target_position(Functions.get_main_level_scene().get_player()), chase_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()


func random_move():
	if cE.state == "dead" or cE.state == "spawn" or modulate.a != 1:
		return
	
	$Tween.stop_all()
	randomize()
	var opt = randi() % 4
	match opt:
		0:
			$Tween.interpolate_property(self, "position", position, Vector2(position.x-40,position.y-40), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		1:
			$Tween.interpolate_property(self, "position", position, Vector2(position.x+40,position.y-40), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)		
		2:
			$Tween.interpolate_property(self, "position", position, Vector2(position.x-40,position.y+40), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)		
		3:
			$Tween.interpolate_property(self, "position", position, Vector2(position.x+40,position.y+40), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)		
	$Tween.start()
	
	
func hurt(damage,weapon_position):
	
	if cE.state != "dead" and cE.hp_now > 0 and modulate.a == 1:
		#$Tween.stop_all()
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()
		Audio.play_sfx("hit4")
		
		cE.apply_damage(self,damage,weapon_position)
		
		Functions.get_main_level_scene().get_node("Hud").update_boss_bar(cE.hp_now)

		if cE.hp_now <= 0:
			$HitBox.set_deferred("monitoring",false)
			Functions.get_main_level_scene().get_node("Hud").show_flash()
			Functions.get_main_level_scene().get_node("Hud").set_boss_bar_visible(false)
			$Tween.stop_all()
			$Sprite.modulate = Color(1,1,1,1)
			enabled_collisions(false)
			Audio.play_sfx("zombie_roar3")
			Audio.stop_music()
			change_state("dead")
			$Sprite.modulate = Color(1,1,1,1)
			return
		
		$TimerAutoInvoke.start()
		received_hits += 1
		if received_hits == 10 and cE.state != "spawn":
			change_state("spawn")
			received_hits = 0
			$Tween.stop_all()
			#mover a posicion central
			$Tween.interpolate_property(self, "global_position", global_position, center_position_room, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()

	yield($TimerHurt,"timeout")
	random_move()
	cE.update_facing(self,$Sprite)
	$Sprite.modulate = Color(1,1,1,1)

func start_spawn():
	if cE.state != "dead" and player is NodePath:
		get_node(invoke_object).global_position = get_node(player).global_position
		get_node(invoke_object).invoke()
		#print("hacer aparecer skeleton, state:"+state)

func enabled_collisions(val=false):
	if val:
		$CollisionShape2D.set_deferred("disabled",false)
		$HitboxEnemy.set_disabled_collision(false)
	else:
		$HitboxEnemy.set_disabled_collision(true)
		$CollisionShape2D.set_deferred("disabled",true)
	#quitar layer enemy
	#set_collision_layer_bit(2,val)
	#ya no chocará con jugador
	#set_collision_mask_bit(0,val)
	#ni con el arma del jugador
	#set_collision_mask_bit(4,val)

func _on_collision_with_player(body):
	#si se detecta a jugador y solo si ha terminado de aparecer (con modulate)
	if body.is_in_group("player") and modulate.a == 1:
#		body.hurt(id,global_position)
		random_move()
	

func _on_Tween_tween_completed(_object, _key):
	if cE.state == "fly":
		start_chase()


func _on_TimerAutoInvoke_timeout():
	if cE.state != "dead" and cE.hp_now > 0 and cE.state != "spawn":
		change_state("spawn")
		received_hits = 0
		$Tween.stop_all()
		#mover a posicion central
		$Tween.interpolate_property(self, "global_position", global_position, center_position_room, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()

#func _on_Area2DDetectSubweapon_body_entered(body):
#	if body.is_in_group("subweapon"):
#		hurt( body.damage,body.global_position )
