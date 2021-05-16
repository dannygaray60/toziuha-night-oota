extends Node2D

func _ready():
	
	$TouchScreenButton.shape.points = $CollisionPolygon2D.polygon
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		Audio.play_sfx("btn_accept")
