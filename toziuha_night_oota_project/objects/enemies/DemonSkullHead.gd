extends KinematicBody2D

var cE = load("res://scripts/enemy.gd").new()

var fireball = preload("res://objects/EnemyFireBall.tscn")
var fireball_instance = null

#var id = "demon_skull_head"

#si es false, la bola de fuego irá en una curva que caerá por gravedad
export var linear_direction_fireball = true

#máximo de bolas de fuego que tirará 
export(int,1,4) var max_fireballs = 2
#bolas de fuego que ha tirado
var fireballs = 0

#var state = "idle"

#puntos de salud
#var hp_max = Vars.enemy[id]["hp_max"]
#var hp_now = hp_max

#items que deja al morir
#var list_items = Vars.enemy[id]["item_drop"]

#velocidad de movimiento
var velocity = Vector2()

#var facing = 1

var gravity = 700

func _ready():
	cE.set_vars("demon_skull_head")
	
	cE.update_facing(self,$Sprite)
		
	$TimerStart.start()

func _physics_process(delta):
	
	#gravedad
	velocity.y += gravity*delta
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
#	Enemy.check_body_collisions(self)


func hurt(damage,weapon_position):
	if cE.state != "dead":
		cE.update_facing(self,$Sprite)
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()

		velocity.x = 0
		
		Audio.play_sfx("hit4")
		
		cE.apply_damage(self,damage,weapon_position)
		
		if cE.hp_now <= 0:
			die()

func disable_collisions(disable=true):
	$CollisionShape2D.set_deferred("disabled", disable)
	$HitboxEnemy.set_disabled_collision(disable)

func die():
	if cE.state != "dead":
		cE.drop_item_and_show_name(self)
		cE.state = "dead"
		gravity = 0
		$AnimationPlayer.stop()
		disable_collisions(true)
		Audio.play_sfx("smash_wood_pieces")
		$AnimationPlayer.play("death")

func _on_TimerHurt_timeout():
	$Sprite.modulate = Color(1,1,1,1)

func throw_fireball():
	if cE.state != "dead" and $VisibilityNotifier2D.is_on_screen() and fireballs < max_fireballs:
		fireballs += 1
		fireball_instance = fireball.instance()
		fireball_instance.global_position = $Sprite/PositionFireBall.global_position
		fireball_instance.direction = cE.facing
		fireball_instance.linear_direction = linear_direction_fireball
		if !linear_direction_fireball:
			fireball_instance.speed += 30
		Functions.get_main_level_scene().add_child(fireball_instance)
		cE.update_facing(self,$Sprite)


func _on_AnimationPlayer_animation_finished(anim_name):
	#finaliza animacion de lanzar bolas de fuego
	if anim_name == "attack" and cE.state != "dead":
		fireballs = 0
		cE.update_facing(self,$Sprite)
		$AnimationPlayer.play("idle")
	elif anim_name == "death":
		queue_free()

func _on_TimerStart_timeout():
	if cE.state != "dead":
		$AnimationPlayer.play("attack")
