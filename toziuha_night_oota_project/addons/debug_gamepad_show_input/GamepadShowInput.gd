extends Node

#export var dpad_up = ""
#export var dpad_down = ""
#export var dpad_left = ""
#export var dpad_right = ""
#export var btn_start = ""
#export var btn_select = ""
#export var btn_a = ""
#export var btn_b = ""
#export var btn_x = ""
#export var btn_y = ""
#export var btn_l = ""
#export var btn_r = ""

func _ready():
	for n in get_tree().get_nodes_in_group("btn_sprites"):
		n.visible=false	

func _process(_delta):
		
	$Btn/dpad_up.visible = Input.is_action_pressed("ui_up")
	$Btn/dpad_down.visible = Input.is_action_pressed("ui_down")
	$Btn/dpad_left.visible = Input.is_action_pressed("ui_left")
	$Btn/dpad_right.visible = Input.is_action_pressed("ui_right")
	
	$Btn/btn_l.visible = Input.is_action_pressed("ui_focus_prev")
	$Btn/btn_r.visible = Input.is_action_pressed("ui_focus_next")
	
	$Btn/btn_b.visible = Input.is_action_pressed("ui_accept")
	$Btn/btn_x.visible = Input.is_action_pressed("ui_cancel")
	
#	$Btn/btn_y.visible = Input.is_action_pressed("ui_y")
	
	$Btn/btn_start.visible = Input.is_action_pressed("ui_select")
#	$Btn/btn_select.visible = Input.is_action_pressed("ui_select")
