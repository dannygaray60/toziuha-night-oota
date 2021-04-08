extends RigidBody2D

var textures = {
	"1": load("res://assets/sprites/money_bronce1.png"),
	"10": load("res://assets/sprites/money_bronce10.png"),
	"50": load("res://assets/sprites/money_silver.png"),
	"100": load("res://assets/sprites/money_gold.png"),
	"500": load("res://assets/sprites/money_diamond500.png"),
	"1000": load("res://assets/sprites/money_diamond1000.png"),
}

export var money = 1

func _ready():
	
	$coin.texture = textures[str(money)]
	
	$AnimationPlayer.play("idle")


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		Functions.show_hud_notif("%d Cordovas"%[money],1.5)
		Vars.player["money"] += money
		if money <= 100:
			Audio.play_sfx("coin")
		else:
			Audio.play_sfx("coin2")
		queue_free()
