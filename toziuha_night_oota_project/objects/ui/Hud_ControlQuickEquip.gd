extends Control

var selected_slot = 0

func _ready():
	$SelectSlot0.visible = true
	$SelectSlot1.visible = false

func _process(_delta):

	if visible and (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down")):
		change_slot()

	if visible and (Input.is_action_just_pressed("ui_cancel")):# or Input.is_action_just_pressed("ui_select")):
		hide_menu()
		
	if visible and selected_slot == 1:
		if Input.is_action_just_pressed("ui_left"):
			Audio.play_sfx("checkbox_change_value")
			Vars.player["current_circuit"] = Functions.get_new_position_on_array(Vars.player["elemental_circuits"],Vars.player["current_circuit"],"prev")
			load_elemental_circuits()
		elif Input.is_action_just_pressed("ui_right"):
			Audio.play_sfx("checkbox_change_value")
			Vars.player["current_circuit"] = Functions.get_new_position_on_array(Vars.player["elemental_circuits"],Vars.player["current_circuit"],"next")
			load_elemental_circuits()
	
	elif visible and selected_slot == 0:
		if Input.is_action_just_pressed("ui_left"):
			Audio.play_sfx("checkbox_change_value")
			Vars.player["current_element_item"] = Functions.get_new_position_on_array(Vars.player["elements_items"],Vars.player["current_element_item"],"prev")
			load_elements_and_items()
		elif Input.is_action_just_pressed("ui_right"):
			Audio.play_sfx("checkbox_change_value")
			Vars.player["current_element_item"] = Functions.get_new_position_on_array(Vars.player["elements_items"],Vars.player["current_element_item"],"next")
			load_elements_and_items()
	
func show_menu():
	
	#limpiar iconos de circuitos si no hay ninguno
	if Vars.player["elemental_circuits"].empty():
		$EC_IconM2.frame = 24
		$EC_IconM1.frame = 24
		$EC_Icon.frame = 24
		$EC_Icon2.frame = 24
		$EC_Icon3.frame = 24
	
	if Vars.player["elemental_circuits"].empty():
		$EO_IconM2.frame = 47
		$EO_IconM1.frame = 47
		$EO_Icon.frame = 47
		$EO_Icon2.frame = 47
		$EO_Icon3.frame = 47
	
	
	visible = true
	#get_parent().can_pause = false
	#get_tree().paused = true
	#update_panel_text()
	#change_slot()

	load_elemental_circuits()
	load_elements_and_items()

func hide_menu():
	visible = false
	#get_parent().can_pause = true
	#get_tree().paused = false
	Audio.play_sfx("btn_cancel")
	get_parent().get_node("ControlPause/MarginContainer/HBoxContainer/BtnEquip").focus()

func change_slot():
	
	if !visible:
		return
	
	Audio.play_sfx("checkbox_change_value")
	
	$SelectSlot0.visible = false
	$SelectSlot1.visible = false
	
	if selected_slot == 0:
		selected_slot = 1
	else:
		selected_slot = 0
	
	get_node("SelectSlot"+str(selected_slot)).visible = true

	update_panel_text()

func update_panel_text():
	#colocar info dependiendo del slot seleccionado y el item
	if selected_slot == 1 and get_circuit()["name"] != "":
		$Panel/Margin/VBx/LblTitle.text = "« Elemental Circuit: %s »" % [get_circuit()["name"]]
		$Panel/Margin/VBx/LblDesc.text = get_circuit()["description"]
		$Panel/Margin/VBx/LblReq.text = "Time: %s secs - MP: %s" % [str(get_circuit()["time"]).pad_zeros(2),str(get_circuit()["mp_cost"]).pad_zeros(3)]
	elif selected_slot == 0 and Vars.player["current_element_item"] != 0:
		$Panel/Margin/VBx/LblTitle.text = "« %s »" % [ tr(get_element(Vars.player["elements_items"][Vars.player["current_element_item"]])["name"]) ]
		$Panel/Margin/VBx/LblDesc.text = tr(get_element(Vars.player["elements_items"][Vars.player["current_element_item"]])["description"])
		$Panel/Margin/VBx/LblReq.text = "Time: N/A - MP: N/A"		
	else:
		$Panel/Margin/VBx/LblTitle.text = "« Empty Slot »"
		$Panel/Margin/VBx/LblDesc.text = "Description: N/A."
		$Panel/Margin/VBx/LblReq.text = "Time: N/A - MP: N/A"

func load_elemental_circuits():
	#si hay circuitos obtenidos
	if !Vars.player["elemental_circuits"].empty():
		#icono del circuito seleccionado (por defecto 0)
		$EC_Icon.frame = get_circuit()["frame_icon"]
		
		#index de circuito
		var ec_idx = Vars.player["current_circuit"]
		
		#icono previo
		ec_idx = Functions.get_new_position_on_array(Vars.player["elemental_circuits"],ec_idx,"prev")
		$EC_IconM1.frame = get_circuit(Vars.player["elemental_circuits"][ec_idx])["frame_icon"]
		
		#icono previo previo
		ec_idx = Functions.get_new_position_on_array(Vars.player["elemental_circuits"],ec_idx,"prev")
		$EC_IconM2.frame = get_circuit(Vars.player["elemental_circuits"][ec_idx])["frame_icon"]
		
		#icono siguiente
		ec_idx = Functions.get_new_position_on_array(Vars.player["elemental_circuits"],Vars.player["current_circuit"],"next")
		$EC_Icon2.frame = get_circuit(Vars.player["elemental_circuits"][ec_idx])["frame_icon"]
		
		#icono siguiente siguiente
		ec_idx = Functions.get_new_position_on_array(Vars.player["elemental_circuits"],ec_idx,"next")
		$EC_Icon3.frame = get_circuit(Vars.player["elemental_circuits"][ec_idx])["frame_icon"]
	
	update_panel_text()

func load_elements_and_items():
	#icono del elemento seleccionado (por defecto 0)
	$EO_Icon.frame = get_element(Vars.player["elements_items"][Vars.player["current_element_item"]])["frame_icon"] 
	
	#index de elemento
	var eo_idx = Vars.player["current_element_item"]
	
	#icono previo
	eo_idx = Functions.get_new_position_on_array(Vars.player["elements_items"],eo_idx,"prev")
	$EO_IconM1.frame = get_element(Vars.player["elements_items"][eo_idx])["frame_icon"]
	
	#icono previo previo
	eo_idx = Functions.get_new_position_on_array(Vars.player["elements_items"],eo_idx,"prev")
	$EO_IconM2.frame = get_element(Vars.player["elements_items"][eo_idx])["frame_icon"]
	
	#icono siguiente
	eo_idx = Functions.get_new_position_on_array(Vars.player["elements_items"],Vars.player["current_element_item"],"next")
	$EO_Icon2.frame = get_element(Vars.player["elements_items"][eo_idx])["frame_icon"]
	
	#icono siguiente siguiente
	eo_idx = Functions.get_new_position_on_array(Vars.player["elements_items"],eo_idx,"next")
	$EO_Icon3.frame = get_element(Vars.player["elements_items"][eo_idx])["frame_icon"]
	
	update_panel_text()


#obtener diccionario de un circuito en base al id
func get_circuit(id_circuit="current"):
	if id_circuit == "current":
		return Vars.elemental_circuits[Vars.player["elemental_circuits"][Vars.player["current_circuit"]]]
	else:
		return Vars.elemental_circuits[id_circuit]
	

func get_element(id="none"):
	return Vars.equipable_items[id]
