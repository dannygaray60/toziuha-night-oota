extends ParallaxBackground

var Conf = load("res://scripts/config.gd").new()

var lvl = 0

func _enter_tree():
	lvl = Conf.get_conf_value("video", "vfx_lvl", 2)
	#desactivar shaders
	if lvl == 0:
		#edificios ondulantes
		$ParallaxBuilds2/RuinsBuilds.material = null
		$ParallaxBuilds2/RuinsBuilds2.material = null
		$ParallaxBuilds/RuinsBuilds.material = null
		
		
