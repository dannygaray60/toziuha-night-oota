extends VBoxContainer

signal btn_pressed

func go_url(url):
	
	Audio.play_sfx("btn_accept")
	if OS.shell_open(url) == OK:
		emit_signal("btn_pressed")


func _on_Btn_focus_entered():
	Audio.play_sfx("btn_move")
