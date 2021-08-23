extends Node2D


func _ready():
	
	var angle = $B.global_position.angle_to_point($A.global_position)
	print(rad2deg(angle)-90)
