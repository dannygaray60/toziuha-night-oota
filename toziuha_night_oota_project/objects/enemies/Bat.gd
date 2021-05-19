extends KinematicBody2D

var texture_blood_bat = preload("res://assets/sprites/enemy_bloodbat.png")

export var id = "bat"

var facing = -1

var velocity = Vector2(0,0)

var speed = 70

var move_y = 500

var state = "fly"

#puntos de salud
var hp_max = Vars.enemy[id]["hp_max"]
var hp_now = hp_max

#items que deja al morir
var list_items = Vars.enemy[id]["item_drop"]

var player = null

func update_facing():
	if state != "dead":
		facing = Functions.get_new_facing_with_player(self,player)
		#volteo de sprite
		$Sprite.scale.x = -1 * facing

func _ready():
	
	if id == "blood_bat":
		speed += 50
		move_y += 190
		$Sprite.texture = texture_blood_bat
	
	player = Functions.get_main_level_scene().get_player()
	update_facing()

func _physics_process(delta):
	
	if state!="dead":
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			#si colisiona contra jugador
			if collision.collider.is_in_group("player"):
				velocity.x = speed * facing #restaurar movimiento después de chocar
				collision.collider.hurt(id,position)
	else:
		velocity.y += 500 * delta
	
	if $VisibilityNotifier2D.is_on_screen():
		velocity = move_and_slide(velocity)
	
	
func hurt(damage,weapon_position):
	if $TimerHurt.get_time_left() == 0 and state != "dead":
		update_facing()
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()

		velocity = Vector2(0,0)
		
		Audio.play_sfx("knife_stab")
		
		damage = Functions.get_value(damage,"-",Vars.enemy[id]["def"])
		hp_now -= damage
		
		var indicator_position = Vector2(global_position.x,weapon_position.y)
		Functions.show_damage_indicator(damage,indicator_position,"red")
		
		if hp_now <= 0:
			die()
			
func die():
	Audio.play_sfx("crazy_bat_death")
	Functions.show_hud_notif(tr(Vars.enemy[id]["name"]))
	$CollisionShape2D.set_deferred("disabled", true)
	state = "dead"
	$AnimationPlayer.play("death")
	#desactivar colisiones
	set_collision_layer_bit(2,false)
	set_collision_mask_bit(4,false)

#impulso hacia arriba
func _on_TimerJump_timeout():
	if state != "dead":
		velocity.y = 0
		velocity.y = lerp(velocity.y, move_y*-1, 0.2)
		$TimerGravity.start()

#impulso hacia abajo como gravedad
func _on_TimerGravity_timeout():
	if state != "dead":
		velocity.y = 0
		velocity.y = lerp(velocity.y, move_y, 0.2)

func _on_VisibilityNotifier2D_screen_entered():
	if state != "dead" and $VisibilityNotifier2D.is_on_screen():
		state = "fly"
		update_facing()
		velocity.x = speed * facing
		$TimerJump.start()
		$TimerGravity.start()
		$AnimationPlayer.play("fly")

func _on_VisibilityNotifier2D_screen_exited():
	if state != "dead" and $VisibilityNotifier2D.is_on_screen():
		state = "idle"
		update_facing()
		velocity = Vector2(0,0)
		$TimerJump.stop()
		$TimerGravity.stop()
		$AnimationPlayer.stop()
	elif state == "dead":
		queue_free()

func _on_TimerHurt_timeout():
	$Sprite.modulate = Color(1,1,1,1)
	_on_VisibilityNotifier2D_screen_entered()
