extends RigidBody2D

export(String, 
	"melonpan",
	"o",
	"cu",
	"ir",
	"ti"
) var item = "o"


func _ready():
	
	if item in Vars.player["elements_items"]:
		queue_free()
	
	$Sprite.frame = Vars.equipable_items[item]["frame_icon"]


func _on_AreaPick_body_entered(body):
	if body.is_in_group("player"):
		Audio.play_sfx("item_pick1")
		Vars.player["elements_items"].append(item)
		Functions.show_hud_notif(tr(Vars.equipable_items[item]["name"]))
		queue_free()
