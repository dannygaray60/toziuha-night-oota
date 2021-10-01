extends Button

var dir_name = ""
var title = "Title of Level Scene... ... ..."
var description = "Full description of this level... Lorem ipsum dolor sit amet consectetur adipiscing elit luctus, facilisi congue consequat iaculis sagittis orci conubia."
var made_by = "Name Designer (name@mail.com)"
var default_cover = preload("res://assets/img/temporal_background.jpg")
var cover = null
var main_scene = ""

func _ready():
	$MarginContainer/HBoxContainer/VBoxContainer/LblTitle.text = title
	$MarginContainer/HBoxContainer/VBoxContainer/LblDescription.text = description
	if made_by == "Unknown":
		$MarginContainer/HBoxContainer/VBoxContainer/LblDesignerLvl.text = ""
	else:
		$MarginContainer/HBoxContainer/VBoxContainer/LblDesignerLvl.text = "Made by: "+made_by
	if cover != null:
		$MarginContainer/HBoxContainer/TextureRect.texture = cover
	else:
		$MarginContainer/HBoxContainer/TextureRect.texture = default_cover
		
func _on_MainButton_focus_entered():
	Audio.play_sfx("btn_main_menu")
