extends ParallaxBackground
var offset_x = 0
func _process(_delta):
	$ParallaxLayer.set_motion_offset(Vector2(offset_x,0))
	$ParallaxLayer2.set_motion_offset(Vector2(offset_x,0))
	$ParallaxLayer3.set_motion_offset(Vector2(offset_x,0))
	$ParallaxLayer4.set_motion_offset(Vector2(offset_x,0))
	offset_x -= 0.2
