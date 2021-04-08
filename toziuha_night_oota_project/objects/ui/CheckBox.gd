extends CheckBox

var play_sound = true

func _ready():
	update_text()

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

func update_text():
	if pressed:
		$Label.text = "ON"
	else:
		$Label.text = "OFF"

func _on_CheckBox_pressed():
	if play_sound:
		Audio.play_sfx("checkbox_change_value")
	update_text()


func _on_CheckBox_focus_entered():
	if play_sound:
		Audio.play_sfx("btn_move")


func _on_CheckBox_toggled(_button_pressed):
	_on_CheckBox_pressed()
