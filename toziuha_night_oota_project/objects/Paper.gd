extends RigidBody2D

signal start_read

var readed = false

var entered = false

func _ready():
	$ButtonKeyGamepadIcon.visible = false
	
func _process(_delta):
	if !readed and entered and Input.is_action_just_pressed("ui_up"):
		readed = true
		emit_signal("start_read")
		queue_free()


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		$ButtonKeyGamepadIcon.visible = true
		entered = true

func _on_Area2D_body_exited(body):
	if body.is_in_group("player"):
		$ButtonKeyGamepadIcon.visible = false
		entered = false
		

