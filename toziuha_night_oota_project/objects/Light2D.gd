extends Light2D

var Conf = load("res://scripts/config.gd").new()

var lvl = 0

func _ready():
	lvl = Conf.get_conf_value("video", "vfx_lvl", 2)
	
	# niveles 0 y 1 quiere decir que luces2d deben ser desact.
	#y en cambio se usará el modo add del sprite
	if lvl < 2:
		enabled = false
		
		#textura
		$LightAdditive.texture = texture
		#color
		$LightAdditive.self_modulate = color
		#escala
		$LightAdditive.scale = Vector2(texture_scale,texture_scale)
