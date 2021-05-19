extends KinematicBody2D

export var id = "floating_skull"

#puntos de salud
var hp_max = 0
var hp_now = 0

var player = null

var anim_state_machine

var state = "fly"

var list_items = []

var facing = -1

var chasing = false

var tween_duration = 3

func update_facing():

	if state != "dead":

		facing = Functions.get_new_facing_with_player(self,player)

		#volteo de sprite
		$Sprite.scale.x = -1 * facing

func _ready():
	
	#colocar stats de vida
	hp_max = Vars.enemy[id]["hp_max"]
	hp_now = hp_max
	#items que deja al morir
	list_items = Vars.enemy[id]["item_drop"]
	
	player = Functions.get_main_level_scene().get_player()
	update_facing()
	anim_state_machine = $AnimationTree.get("parameters/playback")

func _on_TimerToShow_timeout():
	if $VisibilityEnabler2D.is_on_screen():
		anim_state_machine.travel("fly")

func start_chase():
	if $VisibilityEnabler2D.is_on_screen():
		chasing = true
		var position_end = player.global_position
		position_end.y -= 20
		update_facing()
		$Tween.interpolate_property(self, "position", global_position, position_end, tween_duration, Tween.EASE_OUT, Tween.EASE_OUT)
		$Tween.start()
	
func hurt(damage,weapon_position):
	chasing = false
	$Tween.stop_all()
	if $TimerHurt.get_time_left() == 0:
		$Sprite.modulate = Color(1,0,0,1)
		$TimerHurt.start()
		
		Audio.play_sfx("hit4")
		
		#damage calcule
		#reducir damage gracias a defensa
		damage = Functions.get_value(damage,"-",Vars.enemy[id]["def"])
		hp_now -= damage
		
		var indicator_position = Vector2(global_position.x,weapon_position.y)
		Functions.show_damage_indicator(damage,indicator_position,"red")
		
		if hp_now <= 0:
			die()
			
func die():
	Audio.play_sfx("crazy_bat_death")
	state = "dead"
	anim_state_machine.travel("dead")
	chasing = false
	$Tween.stop_all()

func free_enemy():
	queue_free()

func _on_Tween_tween_completed(_object, _key):
	if state != "dead":
		start_chase()


func _on_TimerHurt_timeout():
	$Sprite.modulate = Color(1,1,1,1)
	if state != "dead":
		start_chase()


func _on_VisibilityEnabler2D_screen_entered():
	if state != "dead":
		if anim_state_machine.get_current_node() == "fly":
			start_chase()
		else:
			anim_state_machine.travel("fly")

			


func _on_VisibilityEnabler2D_screen_exited():
	$Tween.stop_all()


func _on_AreaPlayerIsNear_body_entered(body):
	if body.is_in_group("player"):
		tween_duration = 1
	elif body.is_in_group("enemies"):
		tween_duration += 2
		start_chase()

func _on_AreaPlayerIsNear_body_exited(body):
	if body.is_in_group("player"):
		tween_duration = 3
