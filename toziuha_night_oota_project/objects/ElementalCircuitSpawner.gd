extends Node2D

#objetos
var fulgur_sphaera = preload("res://objects/ObjectsElementalCircuits/FulgurSphaera.tscn")
var hydro_amnis = preload("res://objects/ObjectsElementalCircuits/HydroAmnis.tscn")

var object_instance = null

#el circuito se puede usar
var can_use = false

var changing_circuit = false

var current_circuit_data = {}

#obtener la data del circuito equipado
func load_circuit_data():
	current_circuit_data = Vars.elemental_circuits[Vars.player["elemental_circuits"][Vars.player["current_circuit"]]]
	#icono
	$AllCircuit/Circuit/Icon.frame = current_circuit_data["frame_icon"]

func _ready():
	#la señal del jugador cuando se cancela carga será la misma de cancelar ataque con circuito
	# warning-ignore:return_value_discarded
	get_parent().get_parent().connect("absorb_circuit_canceled",self,"cancel_circuit")
	# warning-ignore:return_value_discarded
	get_parent().get_parent().connect("absorb_circuit_started",self,"_on_player_circuit_started")
	
	hide_circuit()


func _process(_delta):
	
	#detener carga
	if Input.is_action_just_released("ui_down") and changing_circuit:
		cancel_circuit()
		#cancelar animacion de carga en personaje
		get_parent().get_parent().change_state("idle")

#iniciar animacion
func start_circuit():
	changing_circuit = true
	
	if can_use:
		
		load_circuit_data()
		
		#arreglar la direccion de carga respecto si está volteado
		if get_parent().scale.x == -1:
			$CircuitProgressBar.fill_mode = 1
		else:
			$CircuitProgressBar.fill_mode = 0
		
		#reestablecer los decibelios por defecto ya que se usará fadein de sonido
		Audio.get_node("sfx/charging_elemental_circuit2").volume_db = 0
		Audio.play_sfx("charging_elemental_circuit2")
		
		$CircuitProgressBar.value = 0
		
		$AnimationPlayer.play("spin")
		$Tween.interpolate_property($AllCircuit,"scale",$AllCircuit.scale,Vector2(1,1),current_circuit_data["time"])
		$Tween.start()
		
		$CircuitProgressBar.visible = true
		#valor maximo de la barra de carga
		$CircuitProgressBar.max_value = current_circuit_data["time"]
		$Tween.interpolate_property($CircuitProgressBar,"value",0,$CircuitProgressBar.max_value,$CircuitProgressBar.max_value)
		$Tween.start()

#cancelar carga de circuito equipado
func cancel_circuit():
	
	Audio.stop_sfx("charging_elemental_circuit2")
	
	changing_circuit = false
	hide_circuit()
	$AnimationPlayer.stop()

#simplemente ocultar los elementos de la carga de circuito
func hide_circuit():
	$Tween.stop_all()
	#ocultar circuito
	$AllCircuit.scale = Vector2(0,0)
	#ocultar barra de carga del circuito
	$CircuitProgressBar.visible = false


#combrobar si se ha cumplido con los requisitos del circuito activado
func is_completed_requeriments():
	var val = false
	
	match player_circuit():
		"none":
			val = false
		"vita_pecunia":
			if Vars.player["money"] >= 200 and Vars.player["mp_now"] >= Vars.elemental_circuits["vita_pecunia"]["mp_cost"]:
				val = true
		"hydro_amnis":
			if player_element() == "o" and Vars.player["mp_now"] >= Vars.elemental_circuits["hydro_amnis"]["mp_cost"]:
				val = true
		"fulgur_sphaera":
			if player_element() == "cu" and Vars.player["mp_now"] >= Vars.elemental_circuits["fulgur_sphaera"]["mp_cost"]:
				val = true
	return val

#comprobar si el jugador está dentro del area de un circuito a absorber
func is_player_entered_external_circuit():
	for ec in get_tree().get_nodes_in_group("elemental_circuit"):
		if ec.player_entered:
			return true
	return false

#retornar el id de circuito equipado o none
func player_circuit():
	if Vars.player["elemental_circuits"].empty():
		return "none"
	else:
		return Vars.player["elemental_circuits"][Vars.player["current_circuit"]]
#igual con el elemento del primer slot
func player_element():
	if Vars.player["elements_items"].empty():
		return "none"
	else:
		return Vars.player["elements_items"][Vars.player["current_element_item"]]

#lanzar o aplicar el circuito (ya pasó el tiempo de carga)
func activate_circuit():
	match player_circuit():
		"none":
			pass
		#añadir la mitad de la vida al player (no cura estados)
		"vita_pecunia":
			#obtener la mitad del hp maximo
			var recover_hp = int(Vars.player["hp_max"]/2)
			#recuperar salud
			Vars.player["hp_now"] += recover_hp
			#quitar exceso
			if Vars.player["hp_now"] > Vars.player["hp_max"]:
				Vars.player["hp_now"] = Vars.player["hp_max"]
			#restar el costo de maná del circuito
			Vars.player["mp_now"] = Functions.get_value(Vars.player["mp_now"],"-",Vars.elemental_circuits[player_circuit()]["mp_cost"])
			#restar dinero
			Vars.player["money"] = Functions.get_value(Vars.player["money"],"-",200)
			#actualizar datos en hud
			get_parent().get_parent().emit_signal("stats_changed")
		"hydro_amnis":
			#limitar la cantidad de veces para spawnear, máximo 3
			if get_tree().get_nodes_in_group("hydro_amnis").size() > 3:
				Audio.play_sfx("btn_incorrect")
				return
			#restar el costo de maná del circuito
			Vars.player["mp_now"] = Functions.get_value(Vars.player["mp_now"],"-",Vars.elemental_circuits[player_circuit()]["mp_cost"])
			#actualizar datos en hud
			get_parent().get_parent().emit_signal("stats_changed")
			object_instance = hydro_amnis.instance()
			object_instance.position = $AllCircuit.global_position
			#cambiar la direccion dependiendo del facing
			object_instance.direction = get_parent().get_parent().facing
			Functions.get_main_level_scene().add_child(object_instance)
		"fulgur_sphaera":
			#limitar la cantidad de veces para spawnear, máximo 3
			if get_tree().get_nodes_in_group("fulgur_sphaera").size() > 3:
				Audio.play_sfx("btn_incorrect")
				return
			#restar el costo de maná del circuito
			Vars.player["mp_now"] = Functions.get_value(Vars.player["mp_now"],"-",Vars.elemental_circuits[player_circuit()]["mp_cost"])
			#actualizar datos en hud
			get_parent().get_parent().emit_signal("stats_changed")
			object_instance = fulgur_sphaera.instance()
			object_instance.position = Vector2(0,-27)
			get_parent().get_parent().add_child(object_instance)

	#sonido de activacion
	if player_circuit() in ["vita_pecunia"]:
		Audio.play_sfx("potion_use")
	elif player_circuit() in ["hydro_amnis"]:
		Audio.play_sfx("water_pouring")
	else:
		Audio.play_sfx("elemental_circuit_shoot")
		
func _on_Tween_tween_completed(object, key):
	#ha pasado el tiempo necesario para activar el circuito
	if object.name == "AllCircuit" and key == ":scale" and can_use:
		#lanzar circuito
		activate_circuit()
		#quitar animacion
		cancel_circuit()
		#regresar idle de estado al player
		get_parent().get_parent().change_state("idle")

func _on_player_circuit_started():
	#sin circuitos no se hará nada
	if !Vars.player["elemental_circuits"].empty() :
		
		load_circuit_data()
		
		can_use = true
		
		#si el jugador no entró en un circuito externo
		if !is_player_entered_external_circuit():
			#se cumplen con los requisitos del circuito
			if is_completed_requeriments():
				start_circuit()
			else:
				Audio.play_sfx("btn_incorrect")
