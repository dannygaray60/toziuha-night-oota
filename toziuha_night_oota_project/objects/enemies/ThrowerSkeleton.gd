extends KinematicBody2D

var cE = load("res://scripts/enemy.gd").new()

var bone = preload("res://objects/EnemyBoneProyectile.tscn")
var bone_instance = null

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

#var facing = -1
#var state = "walk"
var gravity = 600
var speed = 60

#export var id = "thrower_skeleton"
#var hp_max = Vars.enemy[id]["hp_max"]
#var hp_now = hp_max
#var atk = Vars.enemy[id]["atk"]
#var def = Vars.enemy[id]["def"]
#var default_def = Vars.enemy[id]["def"]

var player = null

func _ready():
	cE.set_vars("thrower_skeleton")
	#cE.connect("collision_with_player",self,"_on_collision_with_player")
	player = Functions.get_main_level_scene().get_player()
	change_state("throw",true)

func change_state(new_state, forced=false):
	if (new_state != cE.state or forced) and cE.state != "dead":
		cE.state = new_state
		$AnimationPlayer.play(cE.state)
		
func _physics_process(delta):
	
	if cE.state == "walk":
		velocity.x = speed * cE.facing

	if is_on_floor() and cE.state in ["idle","dead"]:
		velocity.x = 0

	velocity.y += gravity*delta
	
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	#cE.check_body_collisions(self)
	
	fix_state()
	
func fix_state():
	
#	if velocity.x != 0 and state == "walk" and !$Sprite/RayCast2DDetectFloorFront.is_colliding() and is_on_floor():
#		jump()
	
	if velocity.x != 0 and is_on_floor() and cE.state == "throw":
		velocity.x = 0
		
	if cE.state == "walk" and is_on_floor() and velocity.x == 0:
		change_state("throw")
		


func throw_bone(forced_arc=false):
	if cE.state != "dead" and $VisibilityEnabler2D.is_on_screen() and is_on_floor():
		
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
		bone_instance.direction = cE.facing
		if $Sprite/RayCastDetectPlayerFront.is_colliding() and !forced_arc:
			bone_instance.linear_direction = true
		#aplicar parametros cuand el hueso no va en linea recta
		else:
			bone_instance.speed = bone_parameters[index_parameter][0]
			bone_instance.height_arc = bone_parameters[index_parameter][1]
			
		Functions.get_main_level_scene().add_child(bone_instance)
		cE.update_facing(self,$Sprite)
		
		jump(true)
		
func hurt(damage,weapon_position):
	
	if cE.state != "dead" and cE.hp_now > 0:
		
		velocity.x = 0
		
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()
		Audio.play_sfx("hit4")
		
		cE.apply_damage(self,damage,weapon_position)

		if cE.hp_now <= 0:
			$Sprite.modulate = Color(1,1,1,1)
			$HitboxEnemy.set_disabled_collision(true)
			cE.drop_item_and_show_name(self)
			Audio.play_sfx("smash_wood_pieces")
			change_state("dead")
			$Sprite.modulate = Color(1,1,1,1)
			return

	yield($TimerHurt,"timeout")
	cE.update_facing(self,$Sprite)
	jump(true)
	change_state("walk")
	$Sprite.modulate = Color(1,1,1,1)



func jump(inverse=false):
	
	if !is_on_floor() or cE.state == "dead":
		return
	
	velocity.y = -300
	
	if inverse:
		velocity.x = -50 * cE.facing
	else:
		velocity.x = 50 * cE.facing
		

#--------- señales ------------

func _on_VisibilityEnabler2D_screen_entered():
	cE.update_facing(self,$Sprite)


func _on_AreaDetectPlayerToWalk_body_entered(body):
	if body.is_in_group("player"):
		cE.update_facing(self,$Sprite)
		change_state("walk")


func _on_AreaDetectPlayerToWalk_body_exited(body):
	if body.is_in_group("player"):
		jump(true)
		cE.update_facing(self,$Sprite)
		change_state("throw")

#func _on_collision_with_player():
#	jump(true)


func _on_Area2DDetectPlayerUpDown_body_exited(body):
	if body.is_in_group("player"):
		cE.update_facing(self,$Sprite)
