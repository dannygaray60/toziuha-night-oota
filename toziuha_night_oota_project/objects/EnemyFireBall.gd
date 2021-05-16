extends KinematicBody2D

#si es true la bola irá en linea recta de lo contrario hará una pequeña curva
var linear_direction = false

var inactive = false

var direction = 1

var velocity = Vector2(0,0)

var speed = 50

func _ready():
	speed = speed * direction
	velocity.x = speed
	if !linear_direction:
		velocity.y = -80
	Audio.play_sfx("fireball_enemy")
	$Sprite.scale.x = direction
	$AnimationPlayer.play("show")
	
func _physics_process(delta):
	if !linear_direction:
		velocity.y += 200 *delta
	velocity = move_and_slide(velocity)

func delete_fireball():
	call_deferred("queue_free")


func _on_FireBall_body_entered(body):
	if body.is_in_group("player") and !inactive:
		inactive = true
		speed = 0
		body.hurt("fireball",position)
		$AnimationPlayer.play("end")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "end":
		delete_fireball()


#arma del jugador toca bola de fuego
func _on_Area2D_area_entered(area):
	if area.is_in_group("player_weapon") and area.monitoring:
		Audio.play_sfx("fireball_enemy_destroyed")
		$AnimationPlayer.play("end")


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "end":
		$Area2D/CollisionShape2D.set_deferred("disabled",true)


func _on_VisibilityNotifier2D_screen_exited():
	delete_fireball()
