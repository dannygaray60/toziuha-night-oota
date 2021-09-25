extends CanvasLayer

export(Array, NodePath) var tilemap_nodes
export(Dictionary) var cell_colors
export var zoom = 1.0

var i = 0

func _ready():	
	$PanelContainer/MarginContainer/Control.camera_node = Functions.get_main_level_scene().get_player().get_node("PlayerCamera").get_path()
	
	$PanelContainer/MarginContainer/Control.tilemap_nodes = tilemap_nodes
	$PanelContainer/MarginContainer/Control.cell_colors = cell_colors
	$PanelContainer/MarginContainer/Control.zoom = zoom
	
	for t in tilemap_nodes:
		tilemap_nodes[i] = get_node(t)
		i += 1
	
	$PanelContainer/MarginContainer/Control.set_minimap()
	
