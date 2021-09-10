extends KinematicBody2D

var cE = load("res://scripts/enemy.gd").new()

var velocity = Vector2(0,0)

var inactive = false

#si es true la bola irá en linea recta de lo contrario hará una pequeña curva
var linear_direction = false

var direction = 1

var height_arc = -80

var speed = 70

func _ready():

	cE.set_vars("fireball")
	
	speed = speed * direction
	velocity.x = speed
	
	if !linear_direction:
		velocity.y = height_arc
	

	Audio.play_sfx("fireball_enemy")
	
	$Sprite.scale.x = direction
	$AnimationPlayer.play("show")
	
func _physics_process(delta):
	if !linear_direction:
		velocity.y += 200 *delta
	velocity = move_and_slide(velocity)

func delete_fireball():
	call_deferred("queue_free")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "end":
		delete_fireball()

func hurt(_damage,_weapon_pos):
	inactive = true
	speed = 0
	$CollisionShape2D.set_deferred("disabled",true)
	$HitboxEnemy.set_deferred("monitoring",false)
	Audio.play_sfx("fireball_enemy_destroyed")
	$AnimationPlayer.play("end")

func _on_VisibilityNotifier2D_screen_exited():
	delete_fireball()
