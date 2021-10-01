extends Control

var selected_music = 0
var last_index = 0
var music_list = []

func _ready():
	
	for m in Audio.get_node("music").get_children():
		if !m.name.begins_with("ambient_"):
			music_list.append(m.name)
		
	last_index = music_list.size() - 1
	
	Audio.stop_music()
	
	_player_action("play")

	$Panel/Margin/VBx/NEXT.focus()


func _player_action(action):
	match action:
		"play":
			Audio.play_music(music_list[selected_music],false)
			$Panel1/Margin/HBx/LblNameMusic.text = music_list[selected_music]
			$Panel2.visible = true
			#mostrar el autor de la canción
			if music_list[selected_music] in ["the_mystic_forest","cathedral_theme","caverns_theme"]:
				$Panel2/Margin/HBx/LbArtist.text = "DavidKBD"
			elif music_list[selected_music] in ["xandria's_theme","the_beginning_of_darkness","fatal_answer","prepare_for_war"]:
				$Panel2/Margin/HBx/LbArtist.text = "Lydium Music"
			elif music_list[selected_music] in ["rondo_of_darkness","cave_theme"]:
				$Panel2/Margin/HBx/LbArtist.text = "Arath Project"
			elif music_list[selected_music] == "deep_resonance":
				$Panel2/Margin/HBx/LbArtist.text = "4barrelcarb"
			elif music_list[selected_music] == "war_prelude":
				$Panel2/Margin/HBx/LbArtist.text = "Ogrebane"
			elif music_list[selected_music] == "boss_theme":
				$Panel2/Margin/HBx/LbArtist.text = "remaxim"
			elif music_list[selected_music] == "nameless_symphony":
				$Panel2/Margin/HBx/LbArtist.text = "OrchestrAlone"
			
			else:
				$Panel2/Margin/HBx/LbArtist.text = tr("UNKNOWN")
		"next":
			if selected_music < last_index:
				selected_music += 1
			else:
				selected_music = 0
			_player_action("play")
		"prev":
			if selected_music > 0:
				selected_music -= 1
			else:
				selected_music = last_index
			_player_action("play")
		"stop":
			Audio.stop_music()
		_:
			pass


func _on_BtnMenu_pressed():
	SceneChanger.change_scene("res://screens/MainMenu.tscn")
