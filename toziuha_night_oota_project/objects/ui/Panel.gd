extends PanelContainer

var tres_panels = {
	"red": preload("res://objects/ui/Panel_Red.tres"),
	"red_light": preload("res://objects/ui/Panel_Red_light.tres"),
	"purple": preload("res://objects/ui/Panel_Purple.tres"),
	"purple_light": preload("res://objects/ui/Panel_Purple_light.tres"),
}

func set_color_panel(c="red"):
	add_stylebox_override("panel",tres_panels[c])
