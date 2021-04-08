extends Button

export var sfx_accept_sound = "btn_accept"

var play_sound = true

func _ready():
	$Icon.visible = false

func focus(click=false):
	play_sound = false
	if click:
		grab_click_focus()
	else:
		grab_focus()
	play_sound = true

func set_pressed(opt=false):
	play_sound = false
	pressed = opt
	play_sound = true

func _on_SubButton_focus_entered():
	$TimerPressedFocused.start()
	if play_sound:
		Audio.play_sfx("btn_move")
	$Icon.visible = true

func _on_SubButton_focus_exited():
	if !pressed:
		$Icon.visible = false

#func _process(_delta):
	#si el jugador presiona aceptar estando sobre este botón y esté desactivado
	#causa problemas a la hora de jugar
#	if Input.is_action_just_pressed("ui_accept") and get_focus_owner().get_path() == self.get_path() and disabled:
#		Audio.play_sfx("btn_incorrect")

func _on_SubButton_pressed():
	if $TimerPressedFocused.get_time_left() == 0:
		Audio.play_sfx(sfx_accept_sound)

	
