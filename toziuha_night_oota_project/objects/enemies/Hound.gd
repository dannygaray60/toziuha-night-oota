extends KinematicBody2D

export var id = "cursed_hound"

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

var gravity = 300
var speed = 150

var state = "idle"

#nodo del player
var player = null

var anim_state_machine

var chasing = false

func _ready():
	
	#colocar stats de vida
	hp_max = Vars.enemy[id]["hp_max"]
	hp_now = hp_max
	#items que deja al morir
	list_items = Vars.enemy[id]["item_drop"]
	
	player = Functions.get_main_level_scene().get_player()
	update_facing()
	anim_state_machine = $AnimationTree.get("parameters/playback")
	change_state(state)
	

func change_state(new_state="idle"):
	if new_state != "state":
		state = new_state
		anim_state_machine.travel(new_state)
		
func check_state():
	
	if state == "dead":
		return
	
	if velocity.y > 0 and state != "fall":
		change_state("fall")
		
	if velocity.x != 0 and state != "run" and is_on_floor():
		change_state("run")
		
	if is_on_wall() and is_on_floor():
		change_state("idle")
	
	if velocity.y < 0 and state != "jump":
		update_facing()
		change_state("jump") 
	
	if state == "fall" and is_on_floor():
		if chasing:
			update_facing()
			change_state("run")
			
		else:
			change_state("idle")

		
func jump():
	velocity.y = lerp(velocity.y, jump_speed*-1, 0.8)

func _physics_process(delta):
	
	if state == "run":
		velocity.x = speed*facing

	#gravedad
	velocity.y += gravity*delta
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	if state!="dead":
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			#si colisiona contra jugador
			if collision.collider.is_in_group("player"):
				collision.collider.hurt(id,position)
				
#	if is_on_wall() and is_on_floor():
#		change_state("run")
#		jump()

	check_state()
	
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

		change_state("dead")
		velocity.x = 0
		
		#desactivar colisiones
		set_collision_layer_bit(2,false)
		set_collision_mask_bit(0,false)
		set_collision_mask_bit(4,false)
		
		
		Audio.play_sfx("roar")
		
		#mostrar el nombre del enemigo eliminado
		Functions.show_hud_notif(tr(Vars.enemy[id]["name"]))
		
		#spawnear item como recompensa
		if !list_items.empty():
			randomize()
			list_items.shuffle()
			Functions.spawn_drop_item(list_items[randi()%list_items.size()-1],position)

func update_facing():

	if state != "dead" and is_on_floor():
		
		$TimerChangeFacing.start()
		yield($TimerChangeFacing,"timeout")

		facing = Functions.get_new_facing_with_player(self,player)

		#volteo de sprite
		$Sprite.scale.x = -1 * facing
		
#		if $VisibilityNotifier2D.is_on_screen():
#			change_state("run")

func _on_AreaDetectPlayer_body_entered(body):
	if body.is_in_group("player") and state != "dead":
#		if $AreaDetectPlayer.is_connected("body_entered",self,"_on_AreaDetectPlayer_body_entered"):
#			$AreaDetectPlayer.disconnect("body_entered",self,"_on_AreaDetectPlayer_body_entered")
		Audio.play_sfx("roar2")
#		jump()
#		update_facing()
		change_state("run")


func _on_AreaDetectObstacle_body_entered(body):
	if (body is TileMap or body.is_in_group("enemies")) and is_on_floor() and state != "dead":
		update_facing()
		jump()


func _on_AreaDetectObstacle_body_exited(body):
	if (body is TileMap or body.is_in_group("enemies")) and is_on_floor() and state != "dead":
#		update_facing()
		pass


func _on_VisibilityNotifier2D_screen_exited():
	if state != "dead":
		update_facing()
		change_state("idle")


func _on_TimerHurt_timeout():
	$Sprite.modulate = Color(1,1,1,1)
	if $VisibilityNotifier2D.is_on_screen() and state != "dead":
		change_state("run")


#func _on_AreaDetectPlayer_body_exited(_body):
#	pass # Replace with function body.
