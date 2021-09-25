extends Node

func play_sfx(name_sfx,fadein=false):
	
	if fadein:
		#guardar el db original en la descripcion
		if get_node("sfx/"+name_sfx).editor_description == "":
			get_node("sfx/"+name_sfx).editor_description = str(get_node("sfx/"+name_sfx).volume_db)
		var original_db = int(get_node("sfx/"+name_sfx).editor_description)
		
		get_node("sfx/"+name_sfx).volume_db = -20
		
		$Tween.interpolate_property(
			get_node("sfx/"+name_sfx),
			"volume_db",
			get_node("sfx/"+name_sfx).volume_db,
			original_db,
			1
		)
		$Tween.start()
	
	
	get_node("sfx/"+name_sfx).play()

func stop_sfx(name_sfx):
	get_node("sfx/"+name_sfx).stop()

func play_voice(name_voice):
	get_node("voice/"+name_voice).play()

func play_music(name_music,fadein=true):

	if name_music == "silence":
		stop_music()

#	if name_music != "silence" and !get_node("music/"+name_music).is_playing():
#		stop_music()
#		get_node("music/"+name_music).play()
		
	if name_music != "silence" and !get_node("music/"+name_music).is_playing():
		stop_music()
		if fadein:
			#obtener el volumen maximo
			#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"),linear2db(value))
			#hacer tween al volumen
			
			#guardar el db original en la descripcion
			if get_node("music/"+name_music).editor_description == "":
				get_node("music/"+name_music).editor_description = str(get_node("music/"+name_music).volume_db)
			var original_db = int(get_node("music/"+name_music).editor_description)
			
			
			if fadein:
				get_node("music/"+name_music).volume_db = -30
				$Tween.interpolate_property(
					get_node("music/"+name_music),
					"volume_db",
					get_node("music/"+name_music).volume_db,
					original_db,
					3
				)
				$Tween.start()
			else:
				get_node("music/"+name_music).volume_db = original_db

		get_node("music/"+name_music).play()

func stop_music():
	for m in $music.get_children():
		m.stop()
