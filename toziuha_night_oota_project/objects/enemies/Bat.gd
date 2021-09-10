extends KinematicBody2D

var texture_blood_bat = preload("res://assets/sprites/enemy_bloodbat.png")

var cE = load("res://scripts/enemy.gd").new()

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

var gravity = 90
var speed = 70

#una variacion del murcielago mas rapida
export var blood_bat = false

var direction_y = "up"
var distance_y = 300
var timer_distance_y = 0.3

func _ready():
	
	if blood_bat:
		cE.set_vars("blood_bat")
		distance_y = 350
		timer_distance_y = 0.5
		speed = 120
		$Sprite.texture = texture_blood_bat
	else:
		cE.set_vars("bat")
		
	gravity = distance_y
	$TimerMoveY.wait_time = timer_distance_y
	$TimerMoveY.start()
	change_state("fly",true)

func _physics_process(delta):
	
	if cE.state == "fly":
		velocity.x = speed * cE.facing

	if cE.state in ["sleep","dead"]:
		velocity.x = 0

	if direction_y == "up" and cE.state == "fly":
		velocity.y -= gravity*delta
	if direction_y == "down" and cE.state in ["fly","dead"]:
		velocity.y += gravity*delta
	
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	#cE.check_body_collisions(self)


func change_state(new_state, forced=false):
	if (new_state != cE.state or forced) and cE.state != "dead":
		
		if cE.state == "fly":
			$TimerMoveY.start()
#		else:
#			$TimerMoveY.stop()
			
		cE.state = new_state
		$AnimationPlayer.play(cE.state)
		
func hurt(damage,weapon_position):
	
	if cE.state != "dead" and cE.hp_now > 0:
		
		direction_y = "down"
		cE.state = "sleep"
		velocity = Vector2(0,0)
		$TimerMoveY.stop()
		
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()
		Audio.play_sfx("knife_stab")
		
		cE.apply_damage(self,damage,weapon_position)

		if cE.hp_now <= 0:
			gravity += 200
			$Sprite.modulate = Color(1,1,1,1)
			$HitboxEnemy.set_disabled_collision(true)
			cE.drop_item_and_show_name(self)
			Audio.play_sfx("crazy_bat_death")
			change_state("dead")
			$Sprite.modulate = Color(1,1,1,1)
			return

	yield($TimerHurt,"timeout")
	change_state("fly")
	$TimerMoveY.start()
	cE.update_facing(self,$Sprite)
	$Sprite.modulate = Color(1,1,1,1)

#---------- señales -------------

func _on_TimerMoveY_timeout():
	if cE.state != "dead":
		velocity.y = 0
		if direction_y == "up":
			direction_y = "down"
		else:
			direction_y = "up"

func _on_VisibilityEnabler2D_screen_exited():
	if cE.state == "dead":
		queue_free()
	else:
		cE.update_facing(self,$Sprite)

func _on_VisibilityEnabler2D_screen_entered():
#	position.y = Functions.get_main_level_scene().get_player().position.y - 20
	pass
