extends Node2D

func _ready():
	for l in get_tree().get_nodes_in_group("light2d"):
		l.enabled = false
