extends KinematicBody2D

var cE = load("res://scripts/enemy.gd").new()

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

#var facing = -1
#var state = "walk"
var gravity = 600
var speed = 60

#export var id = "blood_skeleton"
#var hp_max = Vars.enemy[id]["hp_max"]
#var hp_now = hp_max
#var atk = Vars.enemy[id]["atk"]
#var def = Vars.enemy[id]["def"]
#var default_def = Vars.enemy[id]["def"]

func _ready():
	cE.set_vars("blood_skeleton")
	change_state("walk",true)
	
func _physics_process(delta):
	
	if cE.state == "walk":
		velocity.x = speed * cE.facing

	if is_on_floor() and cE.state in ["idle","resurrect","dead"]:
		velocity.x = 0

	velocity.y += gravity*delta
	
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	#cE.check_body_collisions(self)
	
	if is_on_wall():
		cE.inverse_facing($Sprite)
	
func change_state(new_state, forced=false):
	if (new_state != cE.state or forced) and cE.state != "dead":
		cE.state = new_state
		$AnimationPlayer.play(cE.state)

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

	yield($TimerHurt,"timeout")
	change_state("walk")
	cE.update_facing(self,$Sprite)
	$Sprite.modulate = Color(1,1,1,1)
	
#----------- señales ---------------------
	
func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"dead":
			$TimerDead.start()
			#queue_free()
		"resurrect":
			$HitboxEnemy.set_disabled_collision(false)
			cE.hp_now = Vars.enemy[cE.id]["hp_max"]
			change_state("walk")
			cE.update_facing(self,$Sprite,true)

func _on_VisibilityEnabler2D_screen_entered():
	cE.update_facing(self,$Sprite)


func _on_AreaDetectPlayer_body_entered(body):
	if body.is_in_group("player"):
		cE.update_facing(self,$Sprite)


func _on_AreaDetectNoFloor_body_exited(body):
	#si velocity.x es 0, quiere decir que se invierte facing
	#despues de ser resucitado, cosa que se quiere evitar
	if body is TileMap and cE.state != "dead" and velocity.x != 0:
		cE.inverse_facing($Sprite)

#inicia resurrección
func _on_TimerDead_timeout():
	if $VisibilityEnabler2D.is_on_screen():
		Audio.play_sfx("smash_wood_pieces_inverse")
	cE.state = "idle"
	change_state("resurrect")
