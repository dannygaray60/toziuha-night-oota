extends Control

#export(NodePath) var camera_node
var camera_node
export(Array, NodePath) var tilemap_nodes
export(Dictionary) var cell_colors
export var zoom = 1.0

var camera
#onready var camera  = get_node(camera_node)
var tilemaps = []


func set_minimap():
	camera  = get_node(camera_node)

	for node in tilemap_nodes:
		#tilemaps.append(get_node(node)) #se omite esto que lo hará el parent
		tilemaps.append(node)


func get_cells(tilemap : TileMap, id):
	return tilemap.get_used_cells_by_id(id)


func _draw():
	draw_set_transform(rect_size / 2, 0, Vector2.ONE)

	for tilemap in tilemaps:
		
		if tilemap == null:
			return
		
		var camera_position = camera.get_camera_screen_center()
		var camera_cell = tilemap.world_to_map(camera_position)
		var tilemap_offset = camera_cell + (camera_position - tilemap.map_to_world(camera_cell)) / tilemap.cell_size

		for id in cell_colors.keys():
			var color = cell_colors[id]
			var cells = get_cells(tilemap, id)
			for cell in cells:
				draw_rect(Rect2((cell - tilemap_offset) * zoom, Vector2.ONE * zoom), color)

func _process(_delta):
	update()
