extends Node

signal collision_with_player

#referencia del nodo de jugador
var player = null

func check_player_node():
	if player == null:
		player = Functions.get_main_level_scene().get_player()

# ------------ Funciones generales para enemigos --------------

#funcion para comprobar la posicion de personaje y colocar el facing 
#de frente al jugador y de paso voltear el sprite
func update_facing(enemynode=null,sprite=null):

	check_player_node()
	
	if enemynode.state != "dead":

		enemynode.facing = Functions.get_new_facing_with_player(enemynode,player)

		#volteo de sprite
		sprite.scale.x = -1 * enemynode.facing

#voltear sprite y facing con un valor contrario al actual del facing
func inverse_facing(enemynode=null,sprite=null):
	if enemynode.state != "dead":
		enemynode.facing = enemynode.facing * -1
		sprite.scale.x = -1 * enemynode.facing
		
#------- aplicar daño a enemigo --------
func apply_damage(enemynode=null, damage=0, weapon_position=Vector2(0,0), def=0):
		if def == 0:
			def = Vars.enemy[enemynode.id]["def"]
		#damage calcule
		#reducir damage gracias a defensa
		damage = Functions.get_value(damage,"-",def)
		enemynode.hp_now -= damage
		
		var indicator_position = Vector2(enemynode.global_position.x,weapon_position.y)
		Functions.show_damage_indicator(damage,indicator_position,"red")
		

#Spawnear objeto del enemigo cuando muere y mostrar nombre en la esquina como notificacion
func drop_item_and_show_name(enemynode=null):
	#items que deja al morir
	var list_items = Vars.enemy[enemynode.id]["item_drop"]

	#mostrar el nombre del enemigo eliminado
	Functions.show_hud_notif(tr(Vars.enemy[enemynode.id]["name"]))
	
	#spawnear item como recompensa
	if !list_items.empty():
		randomize()
		list_items.shuffle()
		Functions.spawn_drop_item(list_items[randi()%list_items.size()-1],enemynode.position)

#Comprobar si el cuerpo del enemigo ha chocado con algo
#si fue contra jugador se le aplica daño al mismo
func check_body_collisions(enemynode=null):
	if enemynode.state != "dead":

		for i in enemynode.get_slide_count():
			var collision = enemynode.get_slide_collision(i)
			#si colisiona contra jugador
			if collision.collider.is_in_group("player") and collision.collider.has_method("hurt"):
				emit_signal("collision_with_player")
				collision.collider.hurt(enemynode.id,enemynode.position)
				#si este cuerpo lleva veneno
				if enemynode.is_in_group("poison") and collision.collider.has_method("change_condition"):
					collision.collider.change_condition("poison")
