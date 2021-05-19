extends KinematicBody2D

var velocity = Vector2(0,0)

var inactive = false

#si es true la bola irá en linea recta de lo contrario hará una pequeña curva
var linear_direction = false

var direction = 1

var height_arc = -250

var speed = 60

func _ready():
		
	if !linear_direction:
		velocity.y = height_arc
	else:
		speed += 90
		
	speed = speed * direction
	velocity.x = speed
	

	Audio.play_sfx("small_woosh")
	
	$Sprite.scale.x = direction
	
	if direction == -1:
		$AnimationPlayer.play("show")
	else:
		$AnimationPlayer.play_backwards("show")
		
func _physics_process(delta):
	if inactive:
		return
	
	if !linear_direction:
		velocity.y += 500 *delta
	velocity = move_and_slide(velocity)

func delete_bone():
	call_deferred("queue_free")


func _on_FireBall_body_entered(body):
	if body.is_in_group("player") and !inactive:
		inactive = true
		speed = 0
		body.hurt("fireball",position)
		$AnimationPlayer.play("end")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "end":
		delete_bone()


#arma del jugador toca bola de fuego
func _on_Area2D_area_entered(area):
	if area.is_in_group("player_weapon") and area.monitoring:
		Audio.play_sfx("fireball_enemy_destroyed")
		$AnimationPlayer.play("end")


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "end":
		$Area2D/CollisionShape2D.set_deferred("disabled",true)


func _on_VisibilityNotifier2D_screen_exited():
	delete_bone()

func is_inactive(val=false):
	inactive = val
