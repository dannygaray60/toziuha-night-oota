extends HSlider

var play_sound = true

func _ready():
	update_value_label()
	
func focus(click=false):
	play_sound = false
	if click:
		grab_click_focus()
	else:
		grab_focus()
	play_sound = true
	
func set_value(val):
	play_sound = false
	value = val
	play_sound = true

func _on_HSlider_value_changed(value):
	update_value_label(value)
	if play_sound:
		Audio.play_sfx("checkbox_change_value")

func update_value_label(val=value):
	$Label.text = str(val).pad_zeros(3)

func _on_HSlider_focus_entered():
	if play_sound:
		Audio.play_sfx("btn_move")
