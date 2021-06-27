extends Node2D

#func _ready():
#	$AnimationPlayer.play("spin")

func _process(delta):
	
	if Input.is_action_just_pressed("ui_left"):
		$Tween.interpolate_property(self, "rotation_degrees", rotation_degrees, 90, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()
	elif Input.is_action_just_pressed("ui_right"):
		$Tween.interpolate_property(self, "rotation_degrees", rotation_degrees, -90, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		$Tween.start()


func _on_Tween_tween_completed(object, key):
	pass


func _on_Tween_tween_all_completed():
	$Tween.interpolate_property(self, "rotation_degrees", rotation_degrees, 0, 2, Tween.TRANS_LINEAR)
	$Tween.start()
