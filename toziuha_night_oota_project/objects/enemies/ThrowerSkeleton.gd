extends KinematicBody2D

var Enemy = load("res://scripts/enemy.gd").new()

var bone = preload("res://objects/EnemyBoneProyectile.tscn")
var bone_instance = null

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

var facing = -1
var state = "walk"
var gravity = 600
var speed = 60

export var id = "thrower_skeleton"
var hp_max = Vars.enemy[id]["hp_max"]
var hp_now = hp_max
var atk = Vars.enemy[id]["atk"]
var def = Vars.enemy[id]["def"]
var default_def = Vars.enemy[id]["def"]

var player = null

func _ready():
	Enemy.connect("collision_with_player",self,"_on_collision_with_player")
	player = Functions.get_main_level_scene().get_player()
	change_state("throw",true)

func change_state(new_state, forced=false):
	if (new_state != state or forced) and state != "dead":
		state = new_state
		$AnimationPlayer.play(state)
		
func _physics_process(delta):
	
	if state == "walk":
		velocity.x = speed*facing

	if is_on_floor() and state in ["idle","dead"]:
		velocity.x = 0

	velocity.y += gravity*delta
	
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	Enemy.check_body_collisions(self)
	
	fix_state()
	
func fix_state():
	
#	if velocity.x != 0 and state == "walk" and !$Sprite/RayCast2DDetectFloorFront.is_colliding() and is_on_floor():
#		jump()
	
	if velocity.x != 0 and is_on_floor() and state == "throw":
		velocity.x = 0
		
	if state == "walk" and is_on_floor() and velocity.x == 0:
		change_state("throw")
		


func throw_bone(forced_arc=false):
	if state != "dead" and $VisibilityEnabler2D.is_on_screen() and is_on_floor():
		
		#randomizar alcance del hueso lanzado
		randomize()
		#array con speed,height_arc
		var bone_parameters = [[60,-250]] #default
		if position.y > player.position.y:
			#print("arriba")
			bone_parameters = [
				[60,-350],
				[110,-450],
				[100,-300],
				[120,-340],
			]
		else:
			#print("abajo")
			bone_parameters = [
				[60,-150],
				[90,-50],
				[130,-90],
			]

		bone_parameters.shuffle()
		var index_parameter = randi() % bone_parameters.size() - 1
		
		bone_instance = bone.instance()
		bone_instance.global_position = $Sprite/PosSpawnBone.global_position
		bone_instance.direction = facing
		if $Sprite/RayCastDetectPlayerFront.is_colliding() and !forced_arc:
			bone_instance.linear_direction = true
		#aplicar parametros cuand el hueso no va en linea recta
		else:
			bone_instance.speed = bone_parameters[index_parameter][0]
			bone_instance.height_arc = bone_parameters[index_parameter][1]
			
		Functions.get_main_level_scene().add_child(bone_instance)
		Enemy.update_facing(self,$Sprite)
		
		jump(true)
		
func hurt(damage,weapon_position):
	
	if $TimerHurt.get_time_left() == 0 and state != "dead" and hp_now > 0:
		
		velocity.x = 0
		
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()
		Audio.play_sfx("hit4")
		
		Enemy.apply_damage(self,damage,weapon_position)

		if hp_now <= 0:
			$Sprite.modulate = Color(1,1,1,1)
			disable_collisions()
			Enemy.drop_item_and_show_name(self)
			Audio.play_sfx("smash_wood_pieces")
			change_state("dead")
			$Sprite.modulate = Color(1,1,1,1)
			return

	yield($TimerHurt,"timeout")
	Enemy.update_facing(self,$Sprite)
	jump(true)
	change_state("walk")
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


func jump(inverse=false):
	
	if !is_on_floor() or state == "dead":
		return
	
	velocity.y = -300
	
	if inverse:
		velocity.x = -50 * facing
	else:
		velocity.x = 50 * facing
		

#--------- señales ------------

func _on_VisibilityEnabler2D_screen_entered():
	Enemy.update_facing(self,$Sprite)


func _on_AreaDetectPlayerToWalk_body_entered(body):
	if body.is_in_group("player"):
		Enemy.update_facing(self,$Sprite)
		change_state("walk")


func _on_AreaDetectPlayerToWalk_body_exited(body):
	if body.is_in_group("player"):
		jump(true)
		Enemy.update_facing(self,$Sprite)
		change_state("throw")

func _on_collision_with_player():
	jump(true)


func _on_Area2DDetectPlayerUpDown_body_exited(body):
	if body.is_in_group("player"):
		Enemy.update_facing(self,$Sprite)
