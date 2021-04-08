extends CanvasLayer

var debug_variables = {}

var variables_count = 0

var i = 0

var lbl

var just_pressed

func _ready():
	show_screen()
	

func _input(event):
	#si se presiona P, cambiamos el valor del check
	just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_P) and just_pressed:
		$ChkBtnEnable.pressed=!$ChkBtnEnable.pressed
		show_screen()

func _process(_delta):
	
#	print (OS.get_static_memory_usage())
	
	if $ChkBtnEnable.pressed:
	
		$Control/lblFPS.text = "FPS: " + str(Engine.get_frames_per_second())
		
		if variables_count!=debug_variables.size():
			variables_count = debug_variables.size()
			for x in debug_variables.keys():
				lbl = Label.new()
				$Control/Panel/VBxKeys.add_child(lbl)
				lbl.name = x
				lbl.text = x
				lbl.align = Label.ALIGN_RIGHT
				
				lbl = Label.new()
				$Control/Panel/VBxValues.add_child(lbl)
				lbl.name = str(x)
	
		for x in debug_variables:
			get_node("Control/Panel/VBxValues/"+x).text=debug_variables[x]

func show_screen():
	$GamepadShowInput.visible = $ChkBtnEnable.pressed
	$Control.visible = $ChkBtnEnable.pressed
	$Label.visible = $ChkBtnEnable.pressed
	$Label2.visible = $ChkBtnEnable.pressed
	$ChkBtnEnable.visible = $ChkBtnEnable.pressed

func _on_ChkBtnEnable_toggled(_button_pressed):
	show_screen()
