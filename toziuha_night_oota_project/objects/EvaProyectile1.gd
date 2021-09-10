extends RigidBody2D

var cE = load("res://scripts/enemy.gd").new()

var speed = 1.3

func _ready():
	
	cE.set_vars("eva_proyectile1")
	
	var pos = Functions.get_main_level_scene().get_player().global_position
	pos.y -= 25

	#distancia entre los dos puntos
	var distance_between = global_position.distance_to(pos)

	if distance_between < 90:
		speed += 2
	elif distance_between > 180:
		speed -= 0.5
	
	linear_velocity = (pos - global_transform.origin) * speed

	Audio.play_sfx("eva_proyectile_shoot")

func _on_EvaProyectile1_body_entered(body):
#	if body.is_in_group("player"):
#		body.hurt("eva_proyectile1",global_position)
#		queue_free()
	pass


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
