extends Control

var Conf = load("res://scripts/config.gd").new()

export var animated = false

export(String, "automatic","keyboard","gamepad") var show_specific_icon

export(String, "ui_select","ui_left","ui_right","ui_up","ui_down","ui_accept","ui_cancel","ui_focus_prev") var action

func _ready():
	$Label.visible = false
	if animated:
		$AnimationPlayer.play("press_anim")
	update_icon()

func update_icon():
	visible = true
	$Label.visible = false
	var gamepad_icon = "hide"
	match show_specific_icon:
		"automatic":
			gamepad_icon = Conf.get_conf_value("video","icons_buttons","hide")
		_:
			gamepad_icon = show_specific_icon
	
	var icon = Conf.get_conf_value("gamepad_icon",action,0)
	
	#mostrar icono de gamepad
	if gamepad_icon == "gamepad":
		$normal.frame = icon
		$pressed.frame = icon
		$Label.visible = false
		
	#o icono de teclado
	elif gamepad_icon == "keyboard":
		var event = InputEventKey.new()
		for ev in InputMap.get_action_list(action):
			if ev is InputEventKey:
				event = ev
				break
		#obtener el primer eventkey de inputmap del action deseado
		match event.as_text():
			"Enter":
				$normal.frame = 55
				$pressed.frame = 55
			"Escape":
				$normal.frame = 45
				$pressed.frame = 45
			"Tab":
				$normal.frame = 54
				$pressed.frame = 54
			"Backspace":
				$normal.frame = 53
				$pressed.frame = 53
			"Left":
				$normal.frame = 48
				$pressed.frame = 48
			"Right":
				$normal.frame = 49
				$pressed.frame = 49
			"Up":
				$normal.frame = 50
				$pressed.frame = 50
			"Down":
				$normal.frame = 51
				$pressed.frame = 51
			"Shift":
				$normal.frame = 52
				$pressed.frame = 52
			"Control":
				$normal.frame = 46
				$pressed.frame = 46
			"Alt":
				$normal.frame = 47
				$pressed.frame = 47
			_:
				$normal.frame = 44
				$pressed.frame = 44
				if event.as_text() in ["A","B","C","D","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0"]:
					$Label.text = "%s" % event.as_text()
				else:
					$Label.text = "?"
				$Label.visible = true
	#u ocultar icono
	else:
		visible = false
