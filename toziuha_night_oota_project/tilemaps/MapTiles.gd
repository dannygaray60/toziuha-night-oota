extends Node2D

var level_ini = ConfigFile.new()

func _ready():
	
	var err = level_ini.load(Vars.level_dir_path+"/data.ini")
	if err == null:
		return
	
	#tomar las keys de la seccion de mapa
	if level_ini.has_section("map"):
		for r in level_ini.get_section_keys("map"):
			#agregarlo a un diccionario
			Vars.map_rooms[r] = level_ini.get_value("map",r,[])
	

	if !Vars.map_rooms.empty():
		
		#recorrer las habitaciones del diccionario 
		for r in Vars.map_rooms:
			#si el valor de la key del diccionario es array
			#y el nombre de la key está dentro de las habitaciones visitadas
			if Vars.map_rooms[r] is Array and r in Vars.player["visited_rooms"]:
				paint_room(r,Vars.map_rooms[r])
			elif Vars.map_rooms[r] is Array:
				delete_wall_room(Vars.map_rooms[r])

#para pintar el interior de las habitaciones
func paint_room(id_room="",room=[]):

	#nombre del tile con el que se pintará
	var tile_use = "dot visited"
	#room es un array con los tiles a pintar
	#estos valores del array son tres:
	#inicio (X), final (X), inicio (Y), final (Y) 
	if !room.empty():
		#si el jugador se encuentra en la habitacion que se pintará
		#se cambiará el tile a usar
		if Vars.player["current_room"] == id_room:
			tile_use = "dot position"
		
		#recorrer cada fila de la habitacion
		#de arriba hacia abajo
		for row in range(room[2], room[3]+1):
		
			#recorrer las columnas de la fila
			#recorremos cada tile en X. usando inicio y final de columna
			for column in range(room[0], room[1]+1):
				#añadimos el tile "dot visited" o "dot position"
				$Base.set_cellv(Vector2(column,row),$Base.get_tileset().find_tile_by_name(tile_use))

#para borrar las lineas blancas (paredes) cercanas a la habitacion
func delete_wall_room(room=[]):
	#room es un array con los tiles a pintar
	#estos valores del array son tres:
	#inicio (X), final (X), inicio (Y), final (Y) 
	if !room.empty():
		#recorrer cada fila de la habitacion
		#de arriba hacia abajo
		for row in range(room[2], room[3]+1):
		
			#recorrer las columnas de la fila
			#recorremos cada tile en X. usando inicio y final de columna
			for column in range(room[0], room[1]+1):	
				#borrar tiles que rodean el tile central
				#esquina superior izquierda
				$Base.set_cellv(Vector2(column-1,row-1),-1)
				#lado izquierdo
				$Base.set_cellv(Vector2(column-1,row),-1)
				#esquina inferior izquierda
				$Base.set_cellv(Vector2(column-1,row+1),-1)
				#lado inferior
				$Base.set_cellv(Vector2(column,row+1),-1)
				#esquina inferior derecha
				$Base.set_cellv(Vector2(column+1,row+1),-1)
				#lado derecho
				$Base.set_cellv(Vector2(column+1,row),-1)
				#esquina superior derecha
				$Base.set_cellv(Vector2(column+1,row-1),-1)
				#lado superior
				$Base.set_cellv(Vector2(column,row-1),-1)
