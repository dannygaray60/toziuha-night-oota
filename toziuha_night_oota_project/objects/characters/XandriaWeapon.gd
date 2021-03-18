extends Node2D

#nivel del arma 1-3
#export(int, 1, 3) var lvl
var lvl = 1
#cost of stamina
var sp_cost = 10

var voices = ["xandria-attack1","xandria-attack2","xandria-attackfast",null,null,null]
var selected_voice = 3

func _ready():
	
	#quit attack animation
	cancel()
	
	
	#set lvl of weapon
	lvl = Vars.player["weapon_lvl"]
	
	#dependiendo del nivel se necesitará diferente cantidad de stamina
	match lvl:
		1:
			sp_cost = 10
		2:
			sp_cost = 30
		3:
			sp_cost = 50

func cancel():
	$Animation.play("empty")

func attack():
	
	#randomizar cual voz usar para el ataque
	randomize()
	selected_voice = randi() % 6
	if voices[selected_voice] != null:
		Audio.play_voice(voices[selected_voice])
	
	#se necesita minimo de stamina para atacar	
	if Vars.player["sp_now"] < sp_cost:
		return
		
	Vars.player["sp_now"] -= sp_cost
	#evitar valor negativo
	if Vars.player["sp_now"] < 0:
		Vars.player["sp_now"] = 0
	#get_parent equivalente a : ../../
	get_parent().get_parent().emit_signal("stamina_loss")
		
	Audio.play_sfx("whip_woosh")
	Audio.play_sfx("chains")
	$Animation.play("attack_lvl"+str(lvl))


func _on_Area_body_entered(body):
	
	if body.is_in_group("enemies"):
		var total_atk = Vars.player["atk"]
		#daño a la mitad estando envenenado
		if Vars.player["condition"] == "poison":
			total_atk = Vars.player["atk"] / 2
		#camera shake
		get_parent().get_parent().get_node("PlayerCamera").add_trauma(0.3)
		#send hurt data to enemy
		body.hurt(total_atk,global_position)
		
