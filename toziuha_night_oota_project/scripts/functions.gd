extends Node

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
