extends Node2D

var sprite_lvl1 = preload("res://assets/sprites/weapon_xandria_lvl1.png")
var sprite_lvl2 = preload("res://assets/sprites/weapon_xandria_lvl2.png")
var sprite_lvl3 = preload("res://assets/sprites/weapon_xandria_lvl3.png")

#nivel del arma 1-3
#export(int, 1, 3) var lvl
var lvl = 1

var voices = ["xandria-attack1","xandria-attack2","xandria-attackfast",null,null,null]
var selected_voice = 3

func _ready():
	
	#quit attack animation
	cancel()
	
	#set lvl of weapon
	lvl = Vars.player["weapon_lvl"]
	
	#set sprite of weapon
	match lvl:
		2:
			$Sprite.texture = sprite_lvl2
		3:
			$Sprite.texture = sprite_lvl3
		_:
			$Sprite.texture = sprite_lvl1
		

func cancel():
	$Animation.play("empty")

func attack():
	
	#randomizar cual voz usar para el ataque
	randomize()
	selected_voice = randi() % 6
	if voices[selected_voice] != null:
		Audio.play_voice(voices[selected_voice])

	Audio.play_sfx("whip_woosh")
	Audio.play_sfx("chains")
	$Animation.play("attack_lvl"+str(lvl))

func _on_Area_body_entered(body):
	
	if body.is_in_group("enemies"):
		#dependiendo del porcentaje de stamina se dará ese porcentaje en bonus para el ataque
		var total_atk = Vars.player["atk"]
		#añadir atk dependiendo del nivel del arma
		match Vars.player["weapon_lvl"]:
			2:
				total_atk += 10
			3:
				total_atk += 20
		#daño a la mitad estando envenenado
		if Vars.player["condition"] == "poison":
			total_atk = total_atk / 2
		#camera shake
		get_parent().get_parent().get_node("PlayerCamera").add_trauma(0.3,true)
		#send hurt data to enemy
		body.hurt(total_atk,global_position)
		


func _on_Area_area_entered(area):
	if area.is_in_group("torch"):
		area.destroy()
