extends Node

var blood_particle = preload("res://objects/particles/BloodParticle.tscn")
var blood_particle_instance = null

var damage_indicator = preload("res://objects/ui/DamageIndicator.tscn")
var damage_indicator_instance = null

#para establecer, restar o sumar algo a un valor evitando un valor negativo
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

func show_damage_indicator(damage,position_to_show,color="black"): #black, red, green
	damage_indicator_instance = damage_indicator.instance()
	damage_indicator_instance.set_damage(damage,color)
	damage_indicator_instance.position = position_to_show
	get_parent().add_child(damage_indicator_instance)
