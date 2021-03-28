extends VBoxContainer

func go_url(url):
	Audio.play_sfx("potion_use")
	# warning-ignore:return_value_discarded
	OS.shell_open(url)
