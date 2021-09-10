extends Area2D

#class enemy
var cE = load("res://scripts/enemy.gd").new()

func _ready():
	cE.set_vars("curved_axe")
