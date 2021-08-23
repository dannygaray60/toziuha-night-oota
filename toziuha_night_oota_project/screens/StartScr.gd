extends Control

var pressed = false

func _ready():
	
	$AnimationPlayer.play("show")
	
	Audio.play_music("nameless_symphony")
	
	if OS.get_name() == "Android":
		$VBx/LblAndroid.visible = true
	else:
		$VBx/LblPC.visible = true

func _process(_delta):
	
	if !pressed and Input.is_action_just_pressed("ui_accept"):
		pressed = true
		start()
		set_process(false)
	elif Input.is_action_just_pressed("ui_cancel"):
		$TimerStartCinematic.stop()
		_on_TimerStartCinematic_timeout()

func start():
	$VideoPlayer.stop()
	$VideoPlayer.visible = false
	Audio.stop_music()
	$VBx.visible = false
	$CinematicHit.play()
	$AnimationPlayer.play("flash")
	#$Voice.play()
	$TimerEnd.start()


func _on_TimerEnd_timeout():
	SceneChanger.change_scene("res://screens/MainMenu.tscn")


func _on_TimerStartCinematic_timeout():
	Audio.stop_music()
	$VideoPlayer.visible = true
	$VideoPlayer.play()

func _on_VideoPlayer_finished():
	pressed = true
	$BGBlack.visible = true
	_on_TimerEnd_timeout()
