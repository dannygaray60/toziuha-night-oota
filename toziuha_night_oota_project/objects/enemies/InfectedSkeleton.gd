extends KinematicBody2D

var cE = load("res://scripts/enemy.gd").new()

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

#var facing = -1
#var state = "idle"
var gravity = 600
var speed = 60
var can_move = true

func _ready():
	cE.set_vars("infected_skeleton")
	change_state("idle",true)

func _physics_process(delta):
	
	if cE.state == "walk" and can_move:
		velocity.x = speed * cE.facing
	
	if cE.state == "walk_reverse" and can_move:
		velocity.x = (50 * cE.facing) * -1

	if is_on_floor() and cE.state in ["idle","dead"]:
		velocity.x = 0

	velocity.y += gravity*delta
	
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	#Enemy.check_body_collisions(self)
	
	fix_state()

func change_state(new_state, forced=false):
	if new_state != cE.state or forced and cE.state != "dead":# and hp_now > 0:
		
		cE.state = new_state
		
		if cE.state.ends_with("_reverse"):
			$AnimationPlayer.play_backwards(cE.state.replace("_reverse",""))
		else:
			$AnimationPlayer.play(cE.state)
			
func fix_state():
	
	#a veces se reproduce una animacion a pesar de que el enemigo murió
	#con esto evitamos enemigos "fantasmas"
	if cE.hp_now < 0 and $AnimationPlayer.is_playing() and cE.state != "dead":
#		print(state)
		queue_free()

	if cE.state in ["walk"] and is_on_wall():
		$Timer.start(3)
		change_state("walk_reverse")
		yield($Timer,"timeout")
		change_state("walk")
		
		
	if is_on_wall() and cE.state == "walk_reverse":
		jump()
		cE.update_facing(self,$Sprite)
		
func hurt(damage,weapon_position):
	
	if cE.state != "dead" and cE.hp_now > 0:
		
		change_state("idle")
		
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()
		Audio.play_sfx("hit4")
		
		cE.apply_damage(self,damage,weapon_position)

		if cE.hp_now <= 0:
			$Sprite.modulate = Color(1,1,1,1)
			$HitboxEnemy.set_disabled_collision(true)
			cE.drop_item_and_show_name(self)
			Audio.play_sfx("smash_wood_pieces")
			change_state("dead")
			$Sprite.modulate = Color(1,1,1,1)
			return
	
	can_move = false
	yield($TimerHurt,"timeout")
	can_move = true
	change_state("walk")
	cE.update_facing(self,$Sprite)
	$Sprite.modulate = Color(1,1,1,1)
	
func jump(can_jump_on_air=false):
	if is_on_floor() or can_jump_on_air and !$Sprite/RayCastUpWall.is_colliding():
		velocity.y = -200

#----------- señales ---------------------

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"dead":
			queue_free()

func _on_VisibilityEnabler2D_screen_entered():
	if cE.state == "dead":
		return
	
	cE.update_facing(self,$Sprite)
		
	if cE.state == "idle" or cE.state == "walk_reverse":
		change_state("walk")


func _on_AreaDetectNearPlayer_body_entered(body):
	if body.is_in_group("player") and cE.state != "dead":
		change_state("idle")
		$Timer.start(1)
		yield($Timer,"timeout")
		cE.update_facing(self,$Sprite)
		change_state("walk")

func _on_AreaDetectPlayerFrontFloor_body_entered(body):
	if body.is_in_group("player") and cE.state != "dead":
		cE.update_facing(self,$Sprite)
		change_state("walk")
func _on_AreaDetectPlayerFrontFloor_body_exited(body):
	if is_on_floor() and body.is_in_group("player") and cE.state != "dead":
		cE.update_facing(self,$Sprite)
		if $VisibilityEnabler2D.is_on_screen():
			jump()
			change_state("walk")
		else:
			change_state("idle")


func _on_AreaWallHeadFront_body_entered(body):
	if (body is TileMap or body.is_in_group("enemies")) and cE.state != "dead":
		$Timer.start(1)
		change_state("walk_reverse")
		yield($Timer,"timeout")
		change_state("walk")


func _on_AreaDetectWallFloorFront_body_entered(body):
	if body is TileMap and cE.state != "dead":
		jump(true)
		cE.update_facing(self,$Sprite)


func _on_AreaDetectNoFloor_body_exited(body):
	if body is TileMap and cE.state != "dead":
		jump()


func _on_AreaWallHeadBack_body_entered(body):
	if (body.is_in_group("enemies")) and cE.state == "walk_reverse" and cE.state != "dead":
#		$Timer.start(1)
		change_state("walk")
#		yield($Timer,"timeout")
#		change_state("walk")
