extends CanvasLayer

func _ready():
	$Main.modulate.a = 1
	update_stats()
	
func update_stats():
	
	#ocultar el panel del estado del jugador
	if Vars.player["condition"] == "good":
		$Main/Texture/TextureStatusPanel.visible = false
	else:
		$Main/Texture/TextureStatusPanel.visible = true
		
	$Main/Texture/HPBar.max_value = Vars.player["hp_max"]
	$Main/Texture/HPBar.value = Vars.player["hp_now"]
	$Main/Texture/SPBar.max_value = Vars.player["sp_max"]
	$Main/Texture/SPBar.value = Vars.player["sp_now"]
	$Main/Texture/EMBar.max_value = Vars.player["em_max"]
	$Main/Texture/EMBar.value = Vars.player["em_now"]
	$Main/Texture/LblPotionNum.text = str(Vars.player["potion_now"]).pad_zeros(2)
	$Main/Texture/TextureStatusPanel/LblStatus.text = Vars.player["condition"].capitalize()
