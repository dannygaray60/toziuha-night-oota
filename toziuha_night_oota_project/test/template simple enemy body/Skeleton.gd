extends KinematicBody2D

var Enemy = load("res://scripts/enemy.gd").new()

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

var facing = -1
var state = "idle"
var gravity = 600
var speed = 60

var id = "skeleton"
var hp_max = Vars.enemy[id]["hp_max"]
var hp_now = hp_max
var atk = Vars.enemy[id]["atk"]
var def = Vars.enemy[id]["def"]
var default_def = Vars.enemy[id]["def"]

func _ready():
	change_state("idle",true)
	Enemy.update_facing(self,$Sprite)

func _physics_process(delta):
	
	if state in ["walk","run"]:
		velocity.x = speed*facing

	velocity.y += gravity*delta
	
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	Enemy.check_body_collisions(self)

func change_state(new_state, forced=false):
	
	if new_state != state or forced:
		state = new_state
		$AnimationPlayer.play(state)
		
func hurt(damage,weapon_position):
	
	if $TimerHurt.get_time_left() == 0 and state != "dead":
		
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()
		Audio.play_sfx("hit4")
		
		Enemy.apply_damage(self,damage,weapon_position)
		
		if hp_now < 0:
			$Sprite.modulate = Color(1,1,1,1)
			disable_collisions()
			Enemy.drop_item_and_show_name(self)
			Audio.play_sfx("smash_wood_pieces")
			change_state("dead")
			
	yield($TimerHurt,"timeout")
	$Sprite.modulate = Color(1,1,1,1)
	
func disable_collisions():
	#quitar layer enemy
	set_collision_layer_bit(2,false)
	#ya no chocará con jugador
	set_collision_mask_bit(0,false)
	#contra otros enemigos
	set_collision_mask_bit(2,false)
	#ni con el arma del jugador
	set_collision_mask_bit(4,false)

#----------- señales ---------------------

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"dead":
			queue_free()
