extends Node

#debido a bugs de input duplicado se ha separado el up de dpad y joystick
func _process(_delta):
	if Input.is_action_just_pressed("ui_up_joystick"):
		Input.action_press("ui_up")
	elif Input.is_action_just_released("ui_up_joystick"):
		Input.action_release("ui_up")
	
	if Input.is_action_just_pressed("ui_down_joystick"):
		Input.action_press("ui_down")
	elif Input.is_action_just_released("ui_down_joystick"):
		Input.action_release("ui_down")

	if Input.is_action_just_pressed("ui_left_joystick"):
		Input.action_press("ui_left")
	elif Input.is_action_just_released("ui_left_joystick"):
		Input.action_release("ui_left")

	if Input.is_action_just_pressed("ui_right_joystick"):
		Input.action_press("ui_right")
	elif Input.is_action_just_released("ui_right_joystick"):
		Input.action_release("ui_right")
