extends Area2D

export var name_door = ""
export var destiny_path = ""
export var destiny_door = ""

func _ready():
	$TimerDontDetect.start()


func _on_RoomChanger_body_entered(body):
	
	if body.is_in_group("player") and $TimerDontDetect.get_time_left() == 0:
		print("entró player")
		#deshabilitar input
		body.set_process_input(false)
		SceneChanger.change_scene(destiny_path)
