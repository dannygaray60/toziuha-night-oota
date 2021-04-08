extends PanelContainer

func _ready():
	visible = false
	pass

func show_notif(txt="Notif.",time_visible=1):
	$Timer.start(time_visible)
	visible = true
	$Label.text = txt


func _on_Timer_timeout():
	visible = false
