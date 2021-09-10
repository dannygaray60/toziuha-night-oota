extends KinematicBody2D

var cE = load("res://scripts/enemy.gd").new()

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

#var facing = -1
#var state = "walk"
var gravity = 600
var speed = 30

#var id = "armored_skeleton"
#var hp_max = Vars.enemy[id]["hp_max"]
#var hp_now = hp_max
#var atk = Vars.enemy[id]["atk"]
#var def = Vars.enemy[id]["def"]
#var default_atk = Vars.enemy[id]["atk"]
#var default_def = Vars.enemy[id]["def"]

var player_near = false

func _ready():
#	Enemy.connect("collision_with_player",self,"_on_collision_with_player")
	cE.set_vars("armored_skeleton")
	change_state("walk",true)
	
func _physics_process(delta):
	
	if cE.state in ["walk","attack"]:
		velocity.x = speed * cE.facing

	if is_on_floor() and cE.state in ["idle","dead"]:
		velocity.x = 0

	velocity.y += gravity*delta
	
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	#Enemy.check_body_collisions(self)
	
	if is_on_wall():
		cE.inverse_facing($Sprite)
		if speed != 30:
			speed = 30
	
func change_state(new_state, forced=false):
	if (new_state != cE.state or forced) and cE.state != "dead":
		cE.state = new_state
		$AnimationPlayer.play(cE.state)

func hurt(damage,weapon_position):
	
	if cE.state != "dead" and cE.hp_now > 0:
		
		if cE.state != "attack":
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
			Audio.play_sfx("box_glass_items_drop_smash")
			change_state("dead")
			$Sprite.modulate = Color(1,1,1,1)
			return

	yield($TimerHurt,"timeout")
	if cE.state != "attack":
		change_state("walk")
	cE.update_facing(self,$Sprite)
	$Sprite.modulate = Color(1,1,1,1)
	
#embestida al atacar, activado desde animationplayer
#ademas aumenta poder de ataque
func move_attack():
	Audio.play_sfx("zombie_roar2")
	Audio.play_sfx("backdash")
#	Vars.enemy[id]["atk"] += 20
	speed = 180


#----------- señales ---------------------
	
func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"attack":
			#Vars.enemy[id]["atk"] = default_atk
			speed = 30
			if !player_near:
				change_state("walk")
			else:
				change_state("idle")
				change_state("attack")
			cE.update_facing(self,$Sprite)
		"dead":
			queue_free()

func _on_VisibilityEnabler2D_screen_entered():
	if cE.state != "attack":
		cE.update_facing(self,$Sprite)


func _on_VisibilityEnabler2D_screen_exited():
	speed = 30

func _on_AreaDetectPlayer_body_entered(body):
	if body.is_in_group("player") and cE.state != "attack":
		cE.update_facing(self,$Sprite)


func _on_Area2DDetectNoFloor_body_exited(body):
	if body is TileMap:
		if speed != 30:
			speed = 30
		if cE.state == "attack":
			change_state("walk")
		elif !$Sprite/Area2DDetectNoFloor/RayCast2D.is_colliding():
			cE.inverse_facing($Sprite)


func _on_Area2DDetectPlayer_body_entered(body):
	if body.is_in_group("player") and cE.state != "attack":
		cE.update_facing(self,$Sprite)


func _on_Area2DDetectPlayerNear_body_entered(body):
	if body.is_in_group("player") and cE.state != "attack":
		player_near = true
		change_state("attack")
		speed = 0

func _on_Area2DDetectPlayerNear_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		
func _on_collision_with_player():
	if cE.state == "attack":
		change_state("walk")
		#Vars.enemy[id]["atk"] = default_atk
		speed = 30

func _on_Area2DSword_body_entered(body):
#	if body.is_in_group("player") and has_method("hurt") and cE.hp_now > 0:
#		body.hurt(id,position)
	pass
