extends Node

var _scn:PackedScene = preload("res://addons/screen_debugger/screen.scn")
var dict:Dictionary = {}
var inst

func _ready():
	inst = _scn.instance()
	get_tree().root.call_deferred("add_child",inst)
	
func _process(_delta):
	inst.debug_variables=dict
