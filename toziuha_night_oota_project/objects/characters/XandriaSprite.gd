extends Sprite

var player_facing = 1

var vel_x = 0

func _ready():
	material.set_shader_param("nb_frames",Vector2(hframes, vframes))


func _process(_delta):
	
	vel_x = get_parent().velocity.x * get_parent().facing
	
	material.set_shader_param("alpha_trail",0)
	material.set_shader_param("frame_coords",0)
	material.set_shader_param("velocity",Vector2(0,0))

	if get_parent().state != "dead" and get_parent().anim_current in ["backdash","pos-backdash"] and vel_x != 0:
		material.set_shader_param("alpha_trail",0.7)
		material.set_shader_param("velocity_max",100)
		material.set_shader_param("trail_size",9)#7
		material.set_shader_param("frame_coords",frame_coords)
		material.set_shader_param("velocity",Vector2(vel_x,0))
	elif get_parent().anim_current in ["slide"] and vel_x != 0:
		material.set_shader_param("alpha_trail",0)
		material.set_shader_param("velocity_max",90)
		material.set_shader_param("trail_size",2)
		material.set_shader_param("frame_coords",frame_coords)
		material.set_shader_param("velocity",Vector2(vel_x,0))
	#si el player murió quitar efecto del shader
	elif get_parent().state == "dead":
		material = null
		set_process(false)
