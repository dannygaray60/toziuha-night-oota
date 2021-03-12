extends CPUParticles2D

func _enter_tree():
	visible = false
	emitting = true
	
func emit():
	visible = true
	emitting = true

#func _ready():
#	emit()


func _on_TimeLife_timeout():
	queue_free()
