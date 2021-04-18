extends CanvasLayer

var Conf = load("res://scripts/config.gd").new()

var crt_filter = preload("res://filters_video/crt_material.tres")
var crt_filter_curved = preload("res://filters_video/crt_material_curved.tres")
var gameboy_filter = preload("res://filters_video/gameboy.tres")

func _ready():
	match Conf.get_conf_value("video","filter","disabled"):
		"disabled":
			$ColorRect.visible = false
		"scanlines":
			$ColorRect.visible = true
			$ColorRect.material = crt_filter
		"scanlines_curved":
			$ColorRect.visible = true
			$ColorRect.material = crt_filter_curved
		"gameboy":
			$ColorRect.visible = true
			$ColorRect.material = gameboy_filter
		
