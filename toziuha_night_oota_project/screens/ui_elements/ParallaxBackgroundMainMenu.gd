extends ParallaxBackground

var offset_x = 0

func _process(_delta):
	offset_x -= 0.5
	set_scroll_offset(Vector2(offset_x,0))
