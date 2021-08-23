extends Node2D

signal circuit_absorbed

export(String, 
	"hability_double_jump",
	"hability_dodge",
	"hability_slide", 
	"hability_circle_whip", 
	"hability_hook_whip", 
	"whip_lvl_2" ,
	"whip_lvl_3",
	"hydro_amnis",
	"vita_pecunia",
	"fulgur_sphaera"
) var circuit = "hability_double_jump"

var player_entered = false

var circuit_hability = true

func _ready():
	
	if was_obtained():
		queue_free()
	
	if Vars.elemental_circuits[circuit]["passive"]:
		$Light2D.color = "ff0000"
		$lighttexture.modulate = "70e10000"
		$TriangleBG/Sprite.frame = 5
		$Circuit/TriangleDown/Sprite.frame = 5
		$Circuit/TriangleUp/Sprite.frame = 4
	
	$Circuit/Icon.frame = Vars.elemental_circuits[circuit]["frame_icon"]
	
	$AnimationPlayer.play("spin")

func was_obtained():
	var result = false
	
	if "hability_" in circuit:
		if Vars.player[circuit]:
			result = true
	
	elif ("whip_lvl_2" in circuit and Vars.player["weapon_lvl"] >= 2) or ("whip_lvl_3" in circuit and Vars.player["weapon_lvl"] >= 3):
		result = true
	elif circuit in Vars.player["elemental_circuits"]:
		result = true
	else:
		result = false
		
	return result

func _on_AreaDetectPlayer_body_entered(body):
	if body.is_in_group("player"):
		player_entered = true
		
		#conectar las señales de player la primera vez
		if body.has_signal("absorb_circuit_started") and !body.is_connected("absorb_circuit_started",self,"_on_absorb_circuit_started"):
			body.connect("absorb_circuit_started",self,"_on_absorb_circuit_started")
			body.connect("absorb_circuit_canceled",self,"_on_absorb_circuit_canceled")


func _on_AreaDetectPlayer_body_exited(body):
	if body.is_in_group("player"):
		player_entered = false
		$AnimationPlayer.playback_speed = 0.1

func _on_absorb_circuit_started():
	if player_entered:
		
		$Tween.interpolate_property($Circuit,"scale",Vector2(1,1),Vector2(0,0),$TimerToAbsorb.wait_time)
		$Tween.start()
		
		$TimerToAbsorb.start()
		$AnimationPlayer.playback_speed = 0.5
	
func _on_absorb_circuit_canceled():
	if player_entered:
		
		$Tween.stop($Circuit,"scale")
		$Tween.interpolate_property($Circuit,"scale",$Circuit.scale,Vector2(1,1),0.3)
		$Tween.start()
		
		$TimerToAbsorb.stop()
		$AnimationPlayer.playback_speed = 0.1


func _on_TimerToAbsorb_timeout():
	
	var player_node = get_tree().get_nodes_in_group("player")[0]
	
	
	Audio.play_sfx("elemental_circuit_absorbed")
	
	$AreaDetectPlayer.monitoring = false
	
	$Tween.interpolate_property(self,"scale",scale,Vector2(3,3),0.3)
	$Tween.start()

	$Tween.interpolate_property(self,"modulate",Color(1,1,1,1),Color(1,1,1,0),0.2)
	$Tween.start()

	player_node.change_state("idle")


	#aplicar el circuito
	if "hability_" in circuit:
		Vars.player[circuit] = true
		
		match circuit:
			"hability_double_jump":
				player_node.show_quick_notif(tr("SKILLDOUBLEJUMP"))
			"hability_slide":
				player_node.show_quick_notif(tr("SKILLSLIDE"))
			"hability_dodge":
				player_node.show_quick_notif(tr("SKILLDODGE"))
			"hability_circle_whip":
				player_node.show_quick_notif(tr("SKILLCIRCLEWHIP"))
			"hability_hook_whip":
				player_node.show_quick_notif(tr("SKILLHOOKWHIP"))
	
	elif "whip_lvl_" in circuit:
		Vars.player["weapon_lvl"] = int(circuit.replace("whip_lvl_",""))
		player_node.weapon_change_level(Vars.player["weapon_lvl"])
		
		player_node.show_quick_notif(tr("WEAPONLVL")%[Vars.player["weapon_lvl"]])
	
	else:
		Vars.player["elemental_circuits"].append(circuit)
		player_node.show_quick_notif( circuit.to_upper().replace("_"," ") )


	emit_signal("circuit_absorbed")

func _on_Tween_tween_completed(object, key):
	if object.name == name and key == ":scale":
		queue_free()
