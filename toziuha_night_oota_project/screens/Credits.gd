extends Control

func _ready():
	Audio.play_music("rondo_of_darkness")
	$SocialAndSupportLinks/Support/TextureButton4.grab_focus()
	#$SocialAndSupportLinks/Support/TextureButton4.grab_focus()


func _process(_delta):
	if Input.is_action_just_pressed("ui_focus_prev"):
		$TextEdit.set_v_scroll( $TextEdit.get_v_scroll()+3 )
	elif Input.is_action_just_pressed("ui_focus_next"):
		$TextEdit.set_v_scroll( $TextEdit.get_v_scroll()-3 )

func _on_SocialAndSupportLinks_btn_pressed():
	$Notif/NotificationInGame.show_notif("Opening external link...",3)


func _on_BtnGoMenu_pressed():
	SceneChanger.change_scene("res://screens/MainMenu.tscn")


func _on_SwipeDetector_swipe_updated(partial_gesture):
	var part_gesture = "up"
	
	part_gesture = partial_gesture.get_direction()
	print(part_gesture)
	match part_gesture:
		"up":
			Input.action_press("ui_focus_prev")
		"down":
			Input.action_press("ui_focus_next")
