extends ParallaxBackground

func _enter_tree():
	
	if OS.get_name() in ["Android"]:
		$ParallaxFire/Fire.material = null
