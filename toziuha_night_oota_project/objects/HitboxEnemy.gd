extends Area2D

var last_impacted_area_name = ""

#paths de las areas que causa daño contiuo
var continuous_areas_entered = []

#act o desactivar colisiones de hitbox
func set_disabled_collision(val=false):
	if val:
		set_deferred("monitoring", false)
	else:
		set_deferred("monitoring", true)
	
	for c in get_children():
		if c is CollisionShape2D or c is CollisionPolygon2D:
			c.set_deferred("disabled", val)

#esta aplica solo con ataques de subarmas y hechizos
func _on_HitboxEnemy_area_body_entered(area):
	if area.is_in_group("player_weapon") and area.monitoring:
		
		#algunas areas harán daño continuo
		if area.is_in_group("continuous_damage"):
			continuous_areas_entered.append(area.get_path())
			_on_TimerContinuousDamage_timeout()
			$TimerContinuousDamage.start()

		#si la ultima area que impacta es la misma anterior mientras el cooldown de invencibilidad esté activa
		#solo para latigo (arma principal
		if area.name in ["AreaLvl1","AreaLvl2","AreaLvl3"] and area.name == last_impacted_area_name and $TimerAvoidDuplicate.get_time_left() != 0:
			return
			
		var total_atk = 0
		
		last_impacted_area_name = area.name
		$TimerAvoidDuplicate.start()
		
		#impacto y calculo de daño
		
		#armas principales ellas tienen su propio calculo de daño
		if area.name in ["AreaLvl1","AreaLvl2","AreaLvl3"]:
			
			total_atk = Vars.player["atk"]
			
			#el titanio da mas cinco de atk
			if Vars.player["elements_items"][Vars.player["current_element_item"]] == "ti":
				total_atk += 5
			
			#añadir atk dependiendo del nivel del arma
			match Vars.player["weapon_lvl"]:
				2:
					total_atk += 1
				3:
					total_atk += 20
		
			#daño a la mitad estando envenenado
			if Vars.player["condition"] == "poison":
				total_atk = total_atk / 2

			#esto pasará si hay un jugador en la escena
			for p in get_tree().get_nodes_in_group("player"):
				#si se ataca en circulo el ataque será solo un minimo
				#solo aplica si el jugador es xandria
				if p.name == "Xandria":
					if p.anim_current == "attack-circle" and total_atk > 5:
						total_atk = int(total_atk / 2.5)
				
				#camera shake
				p.get_node("PlayerCamera").add_trauma(0.2,true)
				
				total_atk = int(total_atk)
		
				#send hurt data to enemy
				get_parent().hurt(total_atk,p.get_node("Sprite/Weapon/PosImpact").global_position)
		
		#daño que produce si el enemigo toca los pies de personaje deslizandose
		#slide damage
		if area.name == "AreaFootSlide":
			total_atk = int( Vars.player["atk"] / 4 )
			get_parent().hurt(total_atk,area.global_position)	
	
		#calculo de daño y aplicarlo si el ataque fue de subarmas o hechizos
		elif area.name == "SubWeaponArea":
			#las subarmas multiplican el poder de ataque base
			total_atk = int( Vars.player["atk"] * Vars.subweapons[area.get_parent().id]["atk_multiplier"] )
			get_parent().hurt(total_atk,area.global_position)
		
		#daño de fulgur sphaera
		elif area.name in ["Sphaera1", "Sphaera1"]:
			if get_parent().cE.hp_now > 0:
				Audio.play_sfx("electric_zap")
			get_parent().hurt(int(Vars.player["atk"]*4),area.global_position)
		
		#hydro amnis
#		elif area.name == "HydroAmnisArea":
#			get_parent().hurt(int(Vars.player["atk"]*2.5),area.global_position)
	
		yield($TimerAvoidDuplicate,"timeout")
		last_impacted_area_name = ""


func _on_TimerContinuousDamage_timeout():
	var area_node = null
	
	if continuous_areas_entered.empty():
		$TimerContinuousDamage.stop()
	
	for a in continuous_areas_entered:
		
		area_node = get_node_or_null(a)
		
		#no existe el nodo
		if area_node == null:
			continuous_areas_entered.erase(a)
		#si el area esta monitoreando y es area 2d
		elif area_node is Area2D and area_node.monitoring:
			match area_node.name:
				#daño de latigo en circulo
				"AreaCircle":
					get_parent().hurt(int(Vars.player["atk"]/3),Vector2(global_position.x,global_position.y-10))
				"HydroAmnisArea":
					get_parent().hurt(int(Vars.player["atk"]*2.5),area_node.global_position)
		#esta el area pero no monitoriza
		elif area_node is Area2D and !area_node.monitoring:
			continuous_areas_entered.erase(a)

func _on_HitboxEnemy_area_exited(area):
	if !is_instance_valid(area):
		return
	if area.is_in_group("player_weapon") and area.monitoring:
		if area.get_path() in continuous_areas_entered:
			continuous_areas_entered.erase(area.get_path())
