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

#export var id = "slime"
#var hp_max = Vars.enemy[id]["hp_max"]
#var hp_now = hp_max
#var atk = Vars.enemy[id]["atk"]
#var def = Vars.enemy[id]["def"]
#var default_def = Vars.enemy[id]["def"]

func _ready():
	cE.set_vars("slime")
	change_state("walk",true)
	
func _physics_process(delta):
	
	if cE.state == "walk":
		velocity.x = speed * cE.facing

	if is_on_floor() and cE.state in ["idle","dead"]:
		velocity.x = 0

	velocity.y += gravity*delta
	
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	#Enemy.check_body_collisions(self)
	
	if is_on_wall() or !$Sprite/RayCastDetectFloor.is_colliding():
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
		Audio.play_sfx("hit2")
		
		cE.apply_damage(self,damage,weapon_position)

		if cE.hp_now <= 0:
			$Sprite.modulate = Color(1,1,1,1)
			$HitboxEnemy.set_disabled_collision(true)
			cE.drop_item_and_show_name(self)
			Audio.play_sfx("hit3")
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
			queue_free()


func _on_VisibilityEnabler2D_screen_entered():
	cE.update_facing(self,$Sprite)


func _on_AreaDetectPlayer_body_entered(body):
	if body.is_in_group("player"):
		cE.update_facing(self,$Sprite)
