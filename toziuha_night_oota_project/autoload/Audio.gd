extends Node


func _ready():
	$music/nameless_symphony.play()

func play_sfx(name_sfx):
	get_node("sfx/"+name_sfx).play()

func play_voice(name_voice):
	get_node("voice/"+name_voice).play()
