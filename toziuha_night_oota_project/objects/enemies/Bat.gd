extends KinematicBody2D

var texture_blood_bat = preload("res://assets/sprites/enemy_bloodbat.png")

var Enemy = load("res://scripts/enemy.gd").new()

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

var facing = -1
var state = "fly"
var gravity = 90
var speed = 70

#una variacion del murcielago mas rapida
export var blood_bat = false

#desde editor cambiar a blood_bat que es una variedad más rápida
export var id = "bat"
var hp_max = Vars.enemy[id]["hp_max"]
var hp_now = hp_max
var atk = Vars.enemy[id]["atk"]
var def = Vars.enemy[id]["def"]
var default_def = Vars.enemy[id]["def"]

var direction_y = "up"
var distance_y = 300
var timer_distance_y = 0.5

func _ready():
	
	if blood_bat:
		id = "blood_bat"
		distance_y = 350
		timer_distance_y = 0.4
		speed = 120
		$Sprite.texture = texture_blood_bat
		
	gravity = distance_y
	$TimerMoveY.wait_time = timer_distance_y
	
	change_state("fly",true)

func _physics_process(delta):
	
	if state == "fly":
		velocity.x = speed*facing

	if state in ["sleep","dead"]:
		velocity.x = 0

	if direction_y == "up" and state == "fly":
		velocity.y -= gravity*delta
	elif direction_y == "down" and state in ["fly","dead"]:
		velocity.y += gravity*delta
	
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	Enemy.check_body_collisions(self)


func change_state(new_state, forced=false):
	if (new_state != state or forced) and state != "dead":
		
		if state == "fly":
			$TimerMoveY.start()
		else:
			$TimerMoveY.stop()
			
		state = new_state
		$AnimationPlayer.play(state)
		
func hurt(damage,weapon_position):
	
	if $TimerHurt.get_time_left() == 0 and state != "dead" and hp_now > 0:
		
		direction_y = "down"
		state = "sleep"
		velocity = Vector2(0,0)
		$TimerMoveY.stop()
		
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()
		Audio.play_sfx("knife_stab")
		
		Enemy.apply_damage(self,damage,weapon_position)

		if hp_now <= 0:
			gravity += 200
			$Sprite.modulate = Color(1,1,1,1)
			disable_collisions()
			Enemy.drop_item_and_show_name(self)
			Audio.play_sfx("crazy_bat_death")
			change_state("dead")
			$Sprite.modulate = Color(1,1,1,1)
			return

	yield($TimerHurt,"timeout")
	change_state("fly")
	Enemy.update_facing(self,$Sprite)
	$Sprite.modulate = Color(1,1,1,1)


func disable_collisions():
	#quitar layer enemy
	set_collision_layer_bit(2,false)
	#ya no chocará con jugador
	set_collision_mask_bit(0,false)
	#contra otros enemigos
	set_collision_mask_bit(2,false)
	#ni con el arma del jugador
	set_collision_mask_bit(4,false)


#---------- señales -------------

func _on_TimerMoveY_timeout():
	velocity.y = 0
	if direction_y == "up":
		direction_y = "down"
	else:
		direction_y = "up"


func _on_VisibilityEnabler2D_screen_exited():
	if state == "dead":
		queue_free()
	else:
		Enemy.update_facing(self,$Sprite)

func _on_VisibilityEnabler2D_screen_entered():
#	position.y = Functions.get_main_level_scene().get_player().position.y - 20
	pass
