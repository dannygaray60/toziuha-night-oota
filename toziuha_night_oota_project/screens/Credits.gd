extends Control

func _ready():
	Audio.play_music("rondo_of_darkness")
	$BtnCrowfunding.grab_focus()
	#$SocialAndSupportLinks/Support/TextureButton4.grab_focus()


func _process(_delta):
	if Input.is_action_just_pressed("ui_focus_prev"):
		$TextEdit.set_v_scroll( $TextEdit.get_v_scroll()+1 )
	elif Input.is_action_just_pressed("ui_focus_next"):
		$TextEdit.set_v_scroll( $TextEdit.get_v_scroll()-1 )

func _on_SocialAndSupportLinks_btn_pressed():
	$Notif/NotificationInGame.show_notif("Opening external link...",3)


func _on_BtnGoMenu_pressed():
	SceneChanger.change_scene("res://screens/MainMenu.tscn")


func _on_BtnCrowfunding_pressed():
	if OS.shell_open("https://ko-fi.com/Blog/Post/Toziuha-Night--Crowdfunding-campaign-E1E85UKXN") == OK:
		$Notif/NotificationInGame.show_notif("Opening external link...",3)


func _on_BtnCrowfunding_focus_entered():
	Audio.play_sfx("btn_move")
