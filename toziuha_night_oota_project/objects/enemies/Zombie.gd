extends KinematicBody2D

#class enemy
var cE = load("res://scripts/enemy.gd").new()

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

var gravity = 600

var speed = 30


func _ready():
	cE.set_vars("zombie")
	change_state("walk")

func _physics_process(delta):
	
	if cE.state == "walk":
		velocity.x = speed * cE.facing

	if is_on_floor() and cE.state in ["idle","dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	#voltear en pared
	if is_on_wall():
		cE.inverse_facing(self.get_node("Sprite"))


func change_state(new_state):
	if new_state != cE.state and cE.state != "dead":
		cE.state = new_state
		$AnimationPlayer.play(cE.state)

func hurt(damage,weapon_position):
	if cE.state != "dead" and cE.hp_now > 0:

		change_state("idle")

		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()
		Audio.play_sfx("knife_stab")

		cE.apply_damage(self,damage,weapon_position)

		if cE.hp_now <= 0:
			$Sprite.modulate = Color(1,1,1,1)
			$HitboxEnemy.set_disabled_collision(true)
			cE.drop_item_and_show_name(self)
			Audio.play_sfx("zombie_roar")
			change_state("dead")
			$Sprite.modulate = Color(1,1,1,1)
			return

	yield($TimerHurt,"timeout")
	change_state("walk")
	cE.update_facing(self,$Sprite)
	$Sprite.modulate = Color(1,1,1,1)

##----------- señales ---------------------
#
func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"dead":
			queue_free()
#
func _on_VisibilityEnabler2D_screen_entered():
	cE.update_facing(self,$Sprite)

func _on_AreaDetectPlayer_body_entered(body):
	if body.is_in_group("player"):
		cE.update_facing(self,$Sprite)
