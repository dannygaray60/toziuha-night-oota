extends KinematicBody2D
var direction = 1
var gravity = 800
var velocity = Vector2.ZERO

var damage = int(Vars.player["atk"]*3)
	
func _physics_process(delta):
	
	velocity.y += gravity * delta
	var collision = move_and_collide(velocity*delta)
	
	if collision != null:
		if collision.collider.is_in_group("enemies"):
			collision.collider.add_collision_exception_with(self)
			collision.collider.hurt(damage,position)

	velocity.x = 100*direction

func _ready():
	if direction == 1:
		$AnimationPlayer.play("show")
	else:
		$Sprite.scale.x = -1
		$AnimationPlayer.play("show_reverse")
	velocity.y -= 400

func play_sound():
	Audio.play_sfx("whip_woosh")


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Area2D_area_entered(area):
	if area.is_in_group("torch"):
		area.destroy()
