extends Node

func play_sfx(name_sfx):
	get_node("sfx/"+name_sfx).play()

func play_voice(name_voice):
	get_node("voice/"+name_voice).play()

func play_music(name_music):

	if name_music == "silence":
		stop_music()

	if name_music != "silence" and !get_node("music/"+name_music).is_playing():
		stop_music()
		get_node("music/"+name_music).play()

func stop_music():
	for m in $music.get_children():
		m.stop()
