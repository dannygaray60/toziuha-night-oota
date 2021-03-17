extends KinematicBody2D

var id = "skeleton"

var hp_max = Vars.enemy[id]["hp_max"]
var hp_now = hp_max

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

export var facing = -1

export var gravity = 600
export var speed = 60

var state = "walk"

func _ready():
	$AnimationPlayer.play("idle")

func _physics_process(delta):

	#gravedad
	velocity.y += gravity*delta
	
	if state!="dead":
	
		if state=="walk":
			velocity.x = speed*facing
		
		velocity = move_and_slide(velocity, Vector2.UP)
		
		if is_on_wall():
			facing = facing * -1
	
	$Sprite.scale.x = -1 * facing

	#-------------- deteccion de colisiones ----------------------
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("player"):
			collision.collider.hurt(id,position)
