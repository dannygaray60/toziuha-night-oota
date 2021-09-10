extends Area2D

var destroyed = false

var i = 0 #la vieja confiable

#probabilidades de spawneo
export var subweapon_shuriken = false
export var subweapon_axe = false
export var weapon_lvl2 = false
export var weapon_lvl3 = false
export(int,0,10) var potion_probability = 0
export(int,0,10) var mp_1_probability = 0
export(int,0,10) var mp_5_probability = 0
export(int,0,10) var money_1_probability = 0
export(int,0,10) var money_10_probability = 0
export(int,0,10) var money_50_probability = 0
export(int,0,10) var money_100_probability = 0
export(int,0,10) var money_500_probability = 0
export(int,0,10) var money_1000_probability = 0

#una "bolsa" que contendrá los items y del cual uno saldrá aleatoriamente
var list_items = []

func _ready():
	$AnimationPlayer.play("idle")
	
	if subweapon_shuriken:
		list_items.push_back("shuriken")
		return
	
	if subweapon_axe:
		list_items.push_back("axe")
		return
	
	if weapon_lvl2:
		list_items.push_back("weapon_lvl2")
		return
	
	if weapon_lvl3:
		list_items.push_back("weapon_lvl3")
		return

	if potion_probability > 0:
		while i < potion_probability:
			list_items.push_back("potion")
			i += 1
			
	if mp_1_probability > 0:
		i = 0
		while i < mp_1_probability:
			list_items.push_back("mp_1")
			i += 1
	
	if mp_5_probability > 0:
		i = 0
		while i < mp_5_probability:
			list_items.push_back("mp_5")
			i += 1

	if money_1_probability > 0:
		i = 0
		while i < money_1_probability:
			list_items.push_back("money_1")
			i += 1

	if money_10_probability > 0:
		i = 0
		while i < money_10_probability:
			list_items.push_back("money_10")
			i += 1
	
	if money_50_probability > 0:
		i = 0
		while i < money_50_probability:
			list_items.push_back("money_50")
			i += 1
	
	if money_100_probability > 0:
		i = 0
		while i < money_100_probability:
			list_items.push_back("money_100")
			i += 1
	
	if money_500_probability > 0:
		i = 0
		while i < money_500_probability:
			list_items.push_back("money_500")
			i += 1
	
	if money_1000_probability > 0:
		i = 0
		while i < money_1000_probability:
			list_items.push_back("money_1000")
			i += 1

	if !list_items.empty():
		randomize()
		list_items.shuffle()

func destroy():
	if !destroyed:
		if !list_items.empty():
			Functions.spawn_drop_item(list_items[0],position)
#		Audio.play_sfx("hit1")
		Audio.play_sfx("torch_destroyed")
		destroyed = true
		$AnimationPlayer.play("destroyed")


func _on_Torch_area_entered(area):
	if area.monitoring and (area.is_in_group("player_weapon") or area.is_in_group("subweapon") or area.is_in_group("elemental_circuit")):
		destroy()
