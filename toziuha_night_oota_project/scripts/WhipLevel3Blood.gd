extends CPUParticles2D

func _enter_tree():
	visible = false
	emitting = true
	
func emit():
	if Vars.player["weapon_lvl"] == 3:
		#restart()
		visible = true
		emitting = true
	
func stop_emit():
#	visible = false
	emitting = false
