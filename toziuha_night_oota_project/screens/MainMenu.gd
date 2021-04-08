extends Control

var Conf = load("res://scripts/config.gd").new()

func _ready():
	Audio.play_music("rondo_of_darkness")
	
	$ButtonListVerticalScroll.elements = [
		["start",tr("START")],
		["download",tr("DOWNLOADMISSIONS")],
		["store",tr("STORE")],
		["extras",tr("EXTRAS")],
		["options",tr("OPTIONS")],
		["credits",tr("CREDITS")],
		["updates",tr("UPDATES")],
		["exit",tr("EXIT")],
	]
	$ButtonListVerticalScroll.update_list()
	
	if !Conf.get_conf_value("touchscreenbutton", "show_buttons",false):
		$BtnUp.visible = false
		$BtnDown.visible = false
		$BtnRight.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		go_to_option($ButtonListVerticalScroll.element)

func go_to_option(opt):
	
	Input.action_release("ui_down")
	Input.action_release("ui_up")
	Input.action_release("ui_accept")
	
	Audio.play_sfx("btn_accept_main_menu")
	match opt:
		"start":
			SceneChanger.change_scene("res://test/Test large corridor.tscn")
		"options":
			SceneChanger.change_scene("res://screens/Options.tscn")
		"exit":
			get_tree().quit()
		_:
			pass

func _on_SwipeDetector_swipe_updated(partial_gesture):
	var part_gesture = "up"
	part_gesture = partial_gesture.get_direction()
	match part_gesture:
		"up":
			Input.action_press("ui_down")
		"down":
			Input.action_press("ui_up")
#		_:
#			Input.action_press("ui_accept")
