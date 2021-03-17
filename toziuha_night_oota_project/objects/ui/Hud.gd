extends CanvasLayer

func _ready():
	$Main.modulate.a = 1
	update_stats()
	
func update_stats():
	$Main/Texture/HPBar.max_value = Vars.player["hp_max"]
	$Main/Texture/HPBar.value = Vars.player["hp_now"]
	$Main/Texture/SPBar.max_value = Vars.player["sp_max"]
	$Main/Texture/SPBar.value = Vars.player["sp_now"]
	$Main/Texture/EPBar.max_value = Vars.player["ep_max"]
	$Main/Texture/EPBar.value = Vars.player["ep_now"]
