extends Area2D



func _on_Area2DStartBossbattle_body_entered(body):
	if body.is_in_group("player"):
#		get_parent().get_node("PuppetMaster").show_body()
#		get_parent().get_node("PuppetMaster2").show_body()
		get_parent().get_parent().get_node("blackshader/AnimationPlayerShader").play("hide")
		disconnect("body_entered",self,"_on_Area2DStartBossbattle_body_entered")
