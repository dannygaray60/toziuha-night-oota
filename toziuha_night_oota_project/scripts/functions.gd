extends Node

var blood_particle = preload("res://objects/particles/BloodParticle.tscn")
var blood_particle_instance = null

var damage_indicator = preload("res://objects/ui/DamageIndicator.tscn")
var damage_indicator_instance = null

#precargar objetos que pueden caer de drops de enemigos y antorchas
var weapon_upgrade = preload("res://objects/items/WeaponUpgrade.tscn")
var money = preload("res://objects/items/MoneyDrop.tscn")
var potion = preload("res://objects/items/Potion.tscn")
var em = preload("res://objects/items/ElementalMaterial.tscn")
var item_drop_instance = null

#obtener el nodo principal que es la base de un nivel
func get_main_level_scene():
	var lvl_base = get_tree().get_nodes_in_group("level_base")
	if lvl_base.size() > 0:
		return lvl_base[0]
	else:
		return null

#para establecer, restar o sumar algo a un valor evitando un valor negativo
#eliminar-----
func get_value(variable,opt,value):
	
	match opt:
		"+":
			variable += value
		"-":
			variable -= value
		"set":
			variable = value
	
	#evitar valores negativos
	if variable < 0:
		variable = 0
	
	return variable

func show_hud_notif(txt="Notif.",time_show=1):
	var panel = get_tree().get_nodes_in_group("hud_notif")
	if panel.size() > 0:
		panel = panel[0]
		panel.show_notif(txt,time_show)
	
#para obtener el anterior/siguiente elemento de un array, a partir del item actual
#arr = array para navegar
#current_pos = posicion actual en el array
#direction = hacia donde movernos en relacion a current_pos (next o prev)
#retornara la nueva posicion dentro del array elegido
func get_new_position_on_array(arr,current_pos=0,direction="prev"):
	# warning-ignore:unused_variable
	var new_pos = 0
	var arr_size = arr.size()
	#si la posicion actual es la ultima del array y queremos ir adelante
	#regresamos a la primera posicion
	if current_pos==arr_size-1 and direction=="next":
		new_pos = 0
	#si la posicion actual es la primera y queremos ir atrás
	#avanzamos hasta la ultima posicion
	elif current_pos==0 and direction=="prev":
		new_pos = arr_size-1
	#las demás posibilidades dentro de los limites anteriores
	else:
		if direction=="next":
			new_pos=current_pos+1
		elif direction=="prev":
			new_pos=current_pos-1
	#si por alguna razon la nueva posicion es mayor o menor del index del array
	#cambiamos este valor a 0
	if new_pos<0 or new_pos>arr_size-1:
		new_pos=0
		print("la nueva posicion sobrepasa index del array, regresamos 0")
	#retornamos valor final, este será la nueva posicion del array
	return new_pos

#para spawnear cualquier item que deja un enemigo al morir o de una antorcha apagada
func spawn_drop_item(itemname,item_position):
	
	if itemname == "none":
		return
	
	var lvl_base = get_main_level_scene()
	var money_num = 1
	if lvl_base != null:
		if itemname.begins_with("money_"):
			item_drop_instance = money.instance()
			item_drop_instance.money = int(itemname.lstrip("money_"))
		elif itemname.begins_with("weapon_lvl"):
			item_drop_instance = weapon_upgrade.instance()
			item_drop_instance.lvl = int(itemname.lstrip("weapon_lvl"))
		elif itemname == "potion":
			item_drop_instance = potion.instance()
		elif itemname.begins_with("em_"):
			item_drop_instance = em.instance()
			item_drop_instance.num = int(itemname.lstrip("em_"))
		#set pos
		item_drop_instance.position = item_position
		#add to scene
		lvl_base.call_deferred("add_child",item_drop_instance)

func show_damage_indicator(damage,position_to_show,color="black"): #black, red, green
	var lvl_base = get_main_level_scene()
	if lvl_base != null:
		damage_indicator_instance = damage_indicator.instance()
		damage_indicator_instance.set_damage(damage,color)
		damage_indicator_instance.position = position_to_show
#		lvl_base.add_child(damage_indicator_instance)
		lvl_base.call_deferred("add_child",damage_indicator_instance)
