extends CanvasLayer

# Intento fallido para crear pantalla adapble a dispositivos de pantalla ancha
#------------------------------

export var move_level_base = true


func _ready():
	$Control.visible = true
	$Timer.start()
	yield($Timer,"timeout")
	update_scr()
#
func _process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		update_scr()

func update_scr():

	if move_level_base:
		
		#obtener la diferencia entre ambas posiciones.x sin signo
		var distance_between = abs(Functions.get_main_level_scene().global_position.x)-abs($Control/AspectRatioContainer/HBoxContainer/Center.rect_global_position.x)
		distance_between = abs(distance_between)
		
		#actualizar posicion del level base
		Functions.get_main_level_scene().global_position = $Control/AspectRatioContainer/HBoxContainer/Center.rect_global_position
		
		var player_camera = Functions.get_main_level_scene().get_player().get_node("PlayerCamera")
		
		for l in get_tree().get_nodes_in_group("camera_delimiter"):
			if l.limit == "TOP-LEFT":
				player_camera.limit_top = l.global_position.y
				player_camera.limit_left = l.global_position.x
			elif l.limit == "BOTTOM-RIGHT":
				player_camera.limit_bottom = l.global_position.y
				player_camera.limit_right = l.global_position.x
		
#		
#
#		 += distance_between * player_camera.zoom.x 
#		player_camera.limit_right += distance_between * player_camera.zoom.x
		



		#mover el level base a la derecha la cantidad de distancia
#		Functions.get_main_level_scene().global_position.x -= distance_between 

		#reajustar camara limite a izq y der solo si se ha cambiado el valor
#		player_camera.limit_left += distance_between #* (player_camera.zoom.x * 3)
#		player_camera.limit_right += distance_between #* (player_camera.zoom.x * 3)


#		print(distance_between)

#funcion que se activa cada vez que se cambia tamaño de pantalla
#func on_screen_resize():
#	update_scr()
