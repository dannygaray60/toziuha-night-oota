extends ScrollContainer

signal scrolled(current_index)

#Special Thanks to "Gamebel Developer" youtube channel for this code
#https://github.com/wongselent/godot-simple-tutorial

export var semitransparent_unfocused_items = true
export(float, 0.5, 1, 0.1) var card_scale = 1
export(float, 1, 2, 0.1) var card_current_scale = 1.3
export(float, 0.1, 1, 0.1) var scroll_duration = 1.3

var can_move_menu = true

export var card_current_index: int = 0
var card_x_positions: Array = []

var card_last_index = 0

onready var scroll_tween: Tween = Tween.new()
onready var margin_r: int = $CenterContainer/MarginContainer.get("custom_constants/margin_right")
onready var card_space: int = $CenterContainer/MarginContainer/HBoxContainer.get("custom_constants/separation")
onready var card_nodes: Array = $CenterContainer/MarginContainer/HBoxContainer.get_children()

var last_action = "none" #none, left or right

#func refresh_vars():
#	margin_r = $CenterContainer/MarginContainer.get("custom_constants/margin_right")
#	card_space = $CenterContainer/MarginContainer/HBoxContainer.get("custom_constants/separation")
#	card_nodes = $CenterContainer/MarginContainer/HBoxContainer.get_children()

func _ready() -> void:

#	refresh_vars()
	
	card_last_index = card_nodes.size()
	if card_last_index != 0:
		card_last_index -= 1
		can_move_menu = true
	else:
		can_move_menu = false
		return
	
	add_child(scroll_tween)
	
	#al cambiar entre sistemas provoca este mensaje de error:
	#resume: Resumed function '_ready()' after yield, but class instance is gone. At script: res://ui_elements/ScrollContainer.gd:43
	yield(get_tree(), "idle_frame")
	
	get_h_scrollbar().modulate.a = 0
	
	for _card in card_nodes:
		var _card_pos_x: float = (margin_r + _card.rect_position.x) - ((rect_size.x - _card.rect_size.x) / 2)
		_card.rect_pivot_offset = (_card.rect_size / 2)
		card_x_positions.append(_card_pos_x)
		
	scroll_horizontal = card_x_positions[card_current_index]
	scroll()


# warning-ignore:unused_argument
func _process(delta: float) -> void:
	
	if !Input.is_action_pressed("ui_up") and !Input.is_action_pressed("ui_down"):
	
		if Input.is_action_just_pressed("ui_right") and can_move_menu:
			$TimerStartAutomove.start()
			last_action = "right"
			#Audio.get_node("ChangeItem").play()
			if card_current_index == card_last_index:
				card_current_index = 0
			else:
				card_current_index += 1
			scroll()
			emit_signal("scrolled",card_current_index)
			return
		
		elif Input.is_action_just_pressed("ui_left") and can_move_menu:
			$TimerStartAutomove.start()
			last_action = "left"
			#Audio.get_node("ChangeItem").play()
			if card_current_index == 0:
				card_current_index = card_last_index
			else:
				card_current_index -= 1
			scroll()
			emit_signal("scrolled",card_current_index)
			return
		
		if Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
			last_action = "none"
			$TimerAutomove.stop()
			$TimerStartAutomove.stop()
	
	for _index in range(card_x_positions.size()):
		var _card_pos_x: float = card_x_positions[_index]
		# warning-ignore:integer_division
		var _swipe_length: float = (card_nodes[_index].rect_size.x / 2) + (card_space / 2)
		var _swipe_current_length: float = abs(_card_pos_x - scroll_horizontal)
		var _card_scale: float = range_lerp(_swipe_current_length, _swipe_length, 0, card_scale, card_current_scale)
		var _card_opacity: float = range_lerp(_swipe_current_length, _swipe_length, 0, 0.3, 1)
		
		_card_scale = clamp(_card_scale, card_scale, card_current_scale)
		_card_opacity = clamp(_card_opacity, 0.3, 1)
		
		card_nodes[_index].rect_scale = Vector2(_card_scale, _card_scale)
		if semitransparent_unfocused_items:
			card_nodes[_index].modulate.a = _card_opacity
		
		if _swipe_current_length < _swipe_length:
			card_current_index = _index




func scroll() -> void:
	
	if !can_move_menu:
		return
	
	# warning-ignore:return_value_discarded
	scroll_tween.interpolate_property(
		self,
		"scroll_horizontal",
		scroll_horizontal,
		card_x_positions[card_current_index],
		scroll_duration,
		Tween.TRANS_BACK,
		Tween.EASE_OUT)
	
	for _index in range(card_nodes.size()):
		var _card_scale: float = card_current_scale if _index == card_current_index else card_scale
		# warning-ignore:return_value_discarded
		scroll_tween.interpolate_property(
			card_nodes[_index],
			"rect_scale",
			card_nodes[_index].rect_scale,
			Vector2(_card_scale,_card_scale),
			scroll_duration,
			Tween.TRANS_QUAD,
			Tween.EASE_OUT)
		if _index == card_current_index:
			card_nodes[_index].grab_focus()
		
	# warning-ignore:return_value_discarded
	scroll_tween.start()


func _on_ScrollContainer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			# warning-ignore:return_value_discarded
			scroll_tween.stop_all()
		else:
			scroll()


func _on_TimerStartAutomove_timeout():
	$TimerAutomove.start()


func _on_TimerAutomove_timeout():
	if last_action != "none" and Input.is_action_pressed("ui_"+last_action):
		Input.action_press("ui_"+last_action)
