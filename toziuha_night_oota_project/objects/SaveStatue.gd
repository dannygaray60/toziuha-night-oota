extends RigidBody2D

var can_save = true

var player_entered = false

func _ready():
	$ButtonKeyGamepadIcon.visible = false
	#si se cargó desde archivo de estatua se reposicionará jugador frente a estatua
	if Vars.loaded_from_statue_save:
		Vars.loaded_from_statue_save = false
		get_tree().get_nodes_in_group("player")[0].position = position

func _process(_delta):
	
	if can_save and Input.is_action_just_pressed("ui_down") and player_entered:
		
		#restaurar salud
		Vars.player["hp_now"] = Vars.player["hp_max"]
		Vars.player["condition"] = "good"
		get_tree().get_nodes_in_group("player")[0].emit_signal("stats_changed")
		
		if Savedata.save_savedata("savegame") == OK:
			can_save = false
			$ButtonKeyGamepadIcon.visible = false
			$AnimatedSprite.animation = "saved"
			Audio.play_sfx("glass_break")
			Functions.show_hud_notif(tr("SAVEDGAME"))
		else:
			Audio.play_sfx("btn_incorrect")
			Functions.show_hud_notif("Error Saving Game")

func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and can_save:
		player_entered = true
		$ButtonKeyGamepadIcon.visible = true


func _on_Area2D_body_exited(body):
	if body.is_in_group("player") and can_save:
		player_entered = false
		$ButtonKeyGamepadIcon.visible = false
