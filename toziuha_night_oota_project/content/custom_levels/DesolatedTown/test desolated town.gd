extends Node2D

func _ready():
	# warning-ignore:return_value_discarded
	DialogBox.connect("dialogbox_closed",self,"_on_DialogClosed")
	Tr._load("res://content/custom_levels/DesolatedTown/end_dialog.ini")

func _on_AnimationPlayerShader_animation_finished(_anim_name):
	#dialogo
	DialogBox.lines = [
		["say","none",Tr._("d1")],
		["say","none",Tr._("d2")],
		["say","none",Tr._("d3")],
		["say","none",Tr._("d4")],
		["say","none",Tr._("d5")],
		["say","none",Tr._("d6")],
		["say","none",Tr._("d7")]
	]
	DialogBox.show_panel("purple")
	
func _on_DialogClosed():
	#mandar a trailer de draculas revenge
	SceneChanger.change_scene("res://content/custom_levels/Dracula'sRevengeTrailer/main.tscn")
