extends CanvasLayer

var hp_danger_bar_sprite = preload("res://assets/sprites/hp_bar_danger.png")
var hp_good_bar_sprite = preload("res://assets/sprites/hp_bar_good.png")

func _ready():
	$Main.modulate.a = 1
	update_stats()
	
func update_stats():
	
	#ocultar el panel del estado del jugador
	if Vars.player["condition"] == "good":
		$Main/Texture/TextureStatusPanel.visible = false
	else:
		$Main/Texture/TextureStatusPanel.visible = true
		
		
	#calcular cual es el porcentaje de vida, si es menos o igual a 20% entonces hay peligro
	var hp_percent = ( float(Vars.player["hp_now"])/float(Vars.player["hp_max"]) ) * 100
	if hp_percent <= 20:
		$Main/Texture/HPBar.texture_progress = hp_danger_bar_sprite
	else:
		$Main/Texture/HPBar.texture_progress = hp_good_bar_sprite
		
		
	$Main/Texture/HPBar.max_value = Vars.player["hp_max"]
	$Main/Texture/HPBar.value = Vars.player["hp_now"]
	$Main/Texture/EMBar.max_value = Vars.player["em_max"]
	$Main/Texture/EMBar.value = Vars.player["em_now"]
	$Main/Texture/LblPotionNum.text = str(Vars.player["potion_now"]).pad_zeros(2)
	$Main/Texture/TextureStatusPanel/LblStatus.text = Vars.player["condition"].capitalize()
