extends Node2D

var voices = ["xandria-attack1","xandria-attack2","xandria-attackfast",null,null,null]
var selected_voice = 3

func _ready():
	cancel()

func cancel():
	$AnimationPlayer.play("empty")

func attack():
	
	#randomizar cual voz usar para el ataque
	randomize()
	selected_voice = randi() % 6
	if voices[selected_voice] != null:
		Audio.play_voice(voices[selected_voice])
		
	Audio.play_sfx("whip_woosh")
	Audio.play_sfx("chains")
	$AnimationPlayer.play("attack")
