extends Area2D

var destroyed = false

func _ready():
	$AnimationPlayer.play("idle")


func _on_Torch_area_body_entered(area_body):
	if !destroyed and area_body.is_in_group("player_weapon"):
		Audio.play_sfx("hit1")
		Audio.play_sfx("torch_destroyed")
		destroyed = true
		$AnimationPlayer.play("destroyed")
