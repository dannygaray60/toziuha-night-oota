extends KinematicBody2D

var Enemy = load("res://scripts/enemy.gd").new()

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

var facing = -1
var state = "walk"
var gravity = 600
var speed = 30

var id = "armored_skeleton"
var hp_max = Vars.enemy[id]["hp_max"]
var hp_now = hp_max
var atk = Vars.enemy[id]["atk"]
var def = Vars.enemy[id]["def"]
var default_atk = Vars.enemy[id]["atk"]
var default_def = Vars.enemy[id]["def"]

var player_near = false

func _ready():
	Enemy.connect("collision_with_player",self,"_on_collision_with_player")
	change_state("walk",true)
	
func _physics_process(delta):
	
	if state in ["walk","attack"]:
		velocity.x = speed*facing

	if is_on_floor() and state in ["idle","dead"]:
		velocity.x = 0

	velocity.y += gravity*delta
	
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	Enemy.check_body_collisions(self)
	
	if is_on_wall():
		Enemy.inverse_facing(self,$Sprite)
		if speed != 30:
			speed = 30
	
func change_state(new_state, forced=false):
	if (new_state != state or forced) and state != "dead":
		state = new_state
		$AnimationPlayer.play(state)

func hurt(damage,weapon_position):
	
	if $TimerHurt.get_time_left() == 0 and state != "dead" and hp_now > 0:
		
		if state != "attack":
			change_state("idle")
		
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()
		Audio.play_sfx("hit4")
		
		Enemy.apply_damage(self,damage,weapon_position)

		if hp_now <= 0:
			$Sprite.modulate = Color(1,1,1,1)
			disable_collisions()
			Enemy.drop_item_and_show_name(self)
			Audio.play_sfx("smash_wood_pieces")
			Audio.play_sfx("box_glass_items_drop_smash")
			change_state("dead")
			$Sprite.modulate = Color(1,1,1,1)
			return

	yield($TimerHurt,"timeout")
	if state != "attack":
		change_state("walk")
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
	
#embestida al atacar, activado desde animationplayer
#ademas aumenta poder de ataque
func move_attack():
	Audio.play_sfx("zombie_roar2")
	Audio.play_sfx("backdash")
	Vars.enemy[id]["atk"] += 20
	speed = 180


#----------- señales ---------------------
	
func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"attack":
			Vars.enemy[id]["atk"] = default_atk
			speed = 30
			if !player_near:
				change_state("walk")
			else:
				change_state("idle")
				change_state("attack")
			Enemy.update_facing(self,$Sprite)
		"dead":
			queue_free()

func _on_VisibilityEnabler2D_screen_entered():
	if state != "attack":
		Enemy.update_facing(self,$Sprite)


func _on_VisibilityEnabler2D_screen_exited():
	speed = 30

func _on_AreaDetectPlayer_body_entered(body):
	if body.is_in_group("player") and state != "attack":
		Enemy.update_facing(self,$Sprite)


func _on_Area2DDetectNoFloor_body_exited(body):
	if body is TileMap:
		if speed != 30:
			speed = 30
		if state == "attack":
			change_state("walk")
		elif !$Sprite/Area2DDetectNoFloor/RayCast2D.is_colliding():
			Enemy.inverse_facing(self,$Sprite)


func _on_Area2DDetectPlayer_body_entered(body):
	if body.is_in_group("player") and state != "attack":
		Enemy.update_facing(self,$Sprite)


func _on_Area2DDetectPlayerNear_body_entered(body):
	if body.is_in_group("player") and state != "attack":
		player_near = true
		change_state("attack")
		speed = 0

func _on_Area2DDetectPlayerNear_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		
func _on_collision_with_player():
	if state == "attack":
		change_state("walk")
		#Vars.enemy[id]["atk"] = default_atk
		speed = 30

func _on_Area2DSword_body_entered(body):
	if body.is_in_group("player") and has_method("hurt") and hp_now > 0:
		body.hurt(id,position)
