extends Node2D

var result = []

func _ready():
	var f = File.new()
	var err = f.open("res://dialogs/test.txt",File.READ)
	if err != OK:
		print("error reading: "+str(err))
		return
		
	#var text = f.get_as_text()
	
	var i = 1
	while not f.eof_reached():
		result.append(f.get_line())
		#print(f.get_line())
	
	
	f.close()
	
	print(result)
