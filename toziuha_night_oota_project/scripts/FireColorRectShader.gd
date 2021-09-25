extends ColorRect

var Conf = load("res://scripts/config.gd").new()

var lvl = 0

func _ready():
	lvl = Conf.get_conf_value("video", "vfx_lvl", 2)
	if lvl == 0:
		material = null
		visible = false
