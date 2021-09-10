extends Node2D

func _ready():
	pass
	Vars.player["hability_double_jump"] = true
	Vars.player["hability_circle_whip"] = true
	#Vars.player["atk"] = 0
	Vars.player["hability_slide"] = true
	Vars.player["mp_now"] = 999
	Vars.player["money"] = 99999
#	Vars.player["hability_hook_whip"] = true
	
	
	Vars.player["elemental_circuits"].append("hydro_amnis")
	Vars.player["elemental_circuits"].append("fulgur_sphaera")
	Vars.player["elements_items"].append("o")
	Vars.player["elements_items"].append("cu")
	Vars.player["current_element_item"] = 1
	Vars.player["current_circuit"] = 0
	
	
	
#	#Vars.player["hability_dodge"] = true
#	Vars.player["hability_slide"] = true
#	#Vars.player["bronze_key"] = true
#	Vars.player["hability_double_jump"] = true
#	#Vars.player["hp_now"] = 01
#	Vars.player["mp_now"] = 15
#
#	DialogBox.show_panel()
	
