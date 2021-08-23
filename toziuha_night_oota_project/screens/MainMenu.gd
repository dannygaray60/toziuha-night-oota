extends Control

var Conf = load("res://scripts/config.gd").new()

func _ready():
	Audio.play_music("rondo_of_darkness")
	
	if OS.get_name() != "Android":
		$HBxPrivacyPolicy.visible = false
	
	$ButtonListVerticalScroll.elements = [
		["start",tr("START")],
#		["download",tr("DOWNLOADMISSIONS")],
#		["store",tr("STORE")],
#		["extras",tr("EXTRAS")],
		["credits",tr("CREDITS")],
		["fanarts","Official Art & Fanarts"],
		["music_box","Music Box"],
		["options",tr("OPTIONS")],
		["updates",tr("UPDATES")],
		["exit",tr("EXIT")],
	]
	$ButtonListVerticalScroll.update_list()

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		if $ControlSocial.visible:
			Audio.play_sfx("btn_accept")
			$ControlSocial.visible = false
		else:
			go_to_option($ButtonListVerticalScroll.element)
	elif Input.is_action_just_pressed("ui_cancel"):
		SceneChanger.change_scene("res://screens/StartScr.tscn")

func go_to_option(opt):
	
	Input.action_release("ui_down")
	Input.action_release("ui_up")
	Input.action_release("ui_accept")
	
	Audio.play_sfx("btn_accept_main_menu")

	match opt:
		"start":
			SceneChanger.change_scene("res://screens/SelectMap.tscn")
		"options":
			SceneChanger.change_scene("res://screens/Options.tscn")
		"credits":
			SceneChanger.change_scene("res://screens/Credits.tscn")
			#$ControlSocial.visible = true
		"fanarts":
			SceneChanger.change_scene("res://screens/Fanarts.tscn")
		"music_box":
			SceneChanger.change_scene("res://screens/MusicPlay.tscn")
		"updates":
			# warning-ignore:return_value_discarded
			OS.shell_open("https://dannygaray60.itch.io/toziuha-night-order-of-the-alchemists?password=xandria")
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

func _on_BtnHideSocialIcons_pressed():
	$ControlSocial.visible = false


func _on_TouchBtnPrivacyPolicy_pressed():
	SceneChanger.change_scene("res://screens/PrivacyPolicy.tscn")
