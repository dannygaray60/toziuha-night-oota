extends VBoxContainer

var elements = [
	["element1","Element 1"],
	["element2","Element 2"],
	["element3","Element 3"],
	["element4","Element 4"],
	["element5","Element 5"],
]
var selected_element = 0

#id del elemento seleccionado para ser usado fuera de este nodo
var element = elements[selected_element][0]

func _ready():
	update_list()
	
func _process(_delta):
	
	if Input.is_action_just_pressed("ui_up"):
		Audio.play_sfx("btn_main_menu")
		selected_element = Functions.get_new_position_on_array(elements,selected_element,"prev")
		update_list()
	elif Input.is_action_just_pressed("ui_down"):
		Audio.play_sfx("btn_main_menu")
		selected_element = Functions.get_new_position_on_array(elements,selected_element,"next")
		update_list()

func update_list():
	
	element = elements[selected_element][0]
	
	var idx_prev = selected_element
	for e in ["Label2","Label1"]:
		idx_prev = Functions.get_new_position_on_array(elements,idx_prev,"prev")
		get_node(e).text = elements[idx_prev][1]
	
	#elemento central
	$Label3.text = elements[selected_element][1]
	
	var idx_next = selected_element
	for e in ["Label4","Label5"]:
		idx_next = Functions.get_new_position_on_array(elements,idx_next,"next")
		get_node(e).text = elements[idx_next][1]
