extends KinematicBody2D

var Enemy = load("res://scripts/enemy.gd").new()

var fireball = preload("res://objects/EnemyFireBall.tscn")
var fireball_instance = null

var id = "demon_skull_head"

#si es false, la bola de fuego irá en una curva que caerá por gravedad
export var linear_direction_fireball = true

#máximo de bolas de fuego que tirará 
export(int,1,4) var max_fireballs = 2
#bolas de fuego que ha tirado
var fireballs = 0

var state = "idle"

#puntos de salud
var hp_max = Vars.enemy[id]["hp_max"]
var hp_now = hp_max

#items que deja al morir
var list_items = Vars.enemy[id]["item_drop"]

#velocidad de movimiento
var velocity = Vector2()

var facing = 1

var gravity = 700

func _ready():
	
	Enemy.update_facing(self,$Sprite)
		
	$TimerStart.start()

func _physics_process(delta):
	
	#gravedad
	velocity.y += gravity*delta
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	Enemy.check_body_collisions(self)


func hurt(damage,weapon_position):
	if $TimerHurt.get_time_left() == 0 and state != "dead":
		Enemy.update_facing(self,$Sprite)
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()

		velocity.x = 0
		
		Audio.play_sfx("hit4")
		
		Enemy.apply_damage(self,damage,weapon_position)
		
		if hp_now <= 0:
			die()

func die():
	if state != "dead":
		Enemy.drop_item_and_show_name(self)
		state = "dead"
		gravity = 0
		$AnimationPlayer.stop()
		$CollisionShape2D.set_deferred("disabled",true)
		Audio.play_sfx("smash_wood_pieces")
		$AnimationPlayer.play("death")

func _on_TimerHurt_timeout():
	$Sprite.modulate = Color(1,1,1,1)

func throw_fireball():
	if state != "dead" and $VisibilityNotifier2D.is_on_screen() and fireballs < max_fireballs:
		fireballs += 1
		fireball_instance = fireball.instance()
		fireball_instance.global_position = $Sprite/PositionFireBall.global_position
		fireball_instance.direction = facing
		fireball_instance.linear_direction = linear_direction_fireball
		if !linear_direction_fireball:
			fireball_instance.speed += 30
		Functions.get_main_level_scene().add_child(fireball_instance)
		Enemy.update_facing(self,$Sprite)


func _on_AnimationPlayer_animation_finished(anim_name):
	#finaliza animacion de lanzar bolas de fuego
	if anim_name == "attack" and state != "dead":
		fireballs = 0
		Enemy.update_facing(self,$Sprite)
		$AnimationPlayer.play("idle")
	elif anim_name == "death":
		queue_free()

func _on_TimerStart_timeout():
	if state != "dead":
		$AnimationPlayer.play("attack")
