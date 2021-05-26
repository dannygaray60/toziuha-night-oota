extends KinematicBody2D

var Enemy = load("res://scripts/enemy.gd").new()

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

var facing = -1
var state = "fly"
var gravity = 600
var speed = 30

var id = "floating_skull"
var hp_max = Vars.enemy[id]["hp_max"]
var hp_now = hp_max
var atk = Vars.enemy[id]["atk"]
var def = Vars.enemy[id]["def"]
var default_def = Vars.enemy[id]["def"]

var chasing = false

var chase_duration = 1

var anim_state_machine

func _ready():
	Enemy.connect("collision_with_player",self,"_on_collision_with_player")
	anim_state_machine = $AnimationTree.get("parameters/playback")
	change_state("pre_show",true)
	
func change_state(new_state, forced=false):
	if (new_state != state or forced) and state != "dead":		
		state = new_state
		anim_state_machine.travel(state)

func get_target_position(targetnode=null):
	randomize()
	var opt = randi() % 4
	var decrease_y = [20,80,30,5]
	decrease_y.shuffle()
	var target_pos = targetnode.position
	target_pos.y -= decrease_y[opt]
	return target_pos

func start_chase():
	if state != "dead":
		$Tween.stop_all()
		randomize()
		if $VisibilityEnabler2D.is_on_screen():
			chase_duration = randi() % 3 + 1
		else:
			chase_duration = 5
		
		Enemy.update_facing(self,$Sprite)
		chasing = true
		$Tween.interpolate_property(self, "position", position, get_target_position(Functions.get_main_level_scene().get_player()), chase_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()


func random_move():
	
	if state == "dead":
		return
	
	$Tween.stop_all()
	randomize()
	var opt = randi() % 4
	match opt:
		0:
			$Tween.interpolate_property(self, "position", position, Vector2(position.x-40,position.y-40), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		1:
			$Tween.interpolate_property(self, "position", position, Vector2(position.x+40,position.y-40), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)		
		2:
			$Tween.interpolate_property(self, "position", position, Vector2(position.x-40,position.y+40), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)		
		3:
			$Tween.interpolate_property(self, "position", position, Vector2(position.x+40,position.y+40), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)		
	$Tween.start()
	
	
func hurt(damage,weapon_position):
	
	if $TimerHurt.get_time_left() == 0 and state != "dead" and hp_now > 0:
		
		$Tween.stop_all()
		
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()
		Audio.play_sfx("hit4")
		
		Enemy.apply_damage(self,damage,weapon_position)

		if hp_now <= 0:
			$Sprite.modulate = Color(1,1,1,1)
			disable_collisions()
			Enemy.drop_item_and_show_name(self)
			Audio.play_sfx("crazy_bat_death")
			change_state("dead")
			$Sprite.modulate = Color(1,1,1,1)
			return

	yield($TimerHurt,"timeout")
	random_move()
	Enemy.update_facing(self,$Sprite)
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

#---------- señales ----------------

func _on_VisibilityEnabler2D_screen_entered():
	change_state("fly")


func _on_Tween_tween_completed(_object, _key):
	if state == "fly":
		start_chase()
		
func _on_collision_with_player(body):
	if body.is_in_group("player"):
		random_move()
