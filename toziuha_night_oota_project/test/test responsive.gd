extends Control

func _process(delta):
	$Node2D.global_position = $AspectRatioContainer/HBoxContainer/ColorRect2.rect_global_position
