extends KinematicBody2D
var direction = 1
var gravity = 800
var velocity = Vector2.ZERO

var on_wall = false

func _ready():
	$TimerEnd.start()
	$Sprite.scale.x = direction
	$AnimationPlayer.play("idle1")
	#velocity.x = 100*direction

func _physics_process(delta):
	
	if is_on_wall() and !on_wall:
		on_wall = true
		$TimerEnd.stop()
		_on_TimerEnd_timeout()
	
	if is_on_floor():
#		if $AnimationPlayer.current_animation == "idle1":
#			$AnimationPlayer.play("pre_idle2")
		velocity.x = 100*direction
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP,true)
	#var collision = move_and_collide(velocity*delta)
	



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "pre_idle2":
		$AnimationPlayer.play("idle2")
	elif anim_name == "end":
		queue_free()
		Audio.stop_sfx("water_fall")

func _on_TimerEnd_timeout():
	$AnimationPlayer.play("end")


func _on_DetectFloor_body_entered(body):
	if body is TileMap and $AnimationPlayer.current_animation == "idle1":
		velocity.y = 0
		$Collision2.set_deferred("disabled",false)
		$AnimationPlayer.play("pre_idle2")
		Audio.play_sfx("water_fall")


func _on_Area2D_area_entered(area_body):
#	if area_body.is_in_group("torch"):
#		area_body.destroy()
#	if area_body.is_in_group("enemies"):
#		$Sprite/Area2D.set_deferred("monitoring",false)
#		area_body.hurt(int(Vars.player["atk"]*2.5),global_position)
#		$Sprite/Area2D.set_deferred("monitoring",true)
	pass
