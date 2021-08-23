extends RigidBody2D

#Functions.get_main_level_scene().get_player().global_position

func _ready():
	var pos = Functions.get_main_level_scene().get_player().global_position
	pos.y -= 25
	linear_velocity = (pos - global_transform.origin) * 2
