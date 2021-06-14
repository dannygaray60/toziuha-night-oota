extends Node

signal scene_changed

onready var anim = $AnimationPlayer
onready var black = $Black

var changing_scene = false
var err

func change_scene(path):
	if ResourceLoader.exists(path):
		changing_scene=true
		yield(get_tree().create_timer(0.1), 'timeout')
		anim.play("fade")
		yield(anim,"animation_finished")
		#por alguna razón assert no funciona en proyectos exportados sin depuracion
		#assert(get_tree().change_scene(path) == OK)
		err = get_tree().change_scene(path) #guardar cualquier error al cambiar escena
		anim.play_backwards("fade")
		yield(anim,"animation_finished")
		changing_scene=false
		emit_signal("scene_changed")
	else:
		print("Failed to change scene, %s doesn't exists."%[path])
