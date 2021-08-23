extends Node2D

var random = true

#export(String, "zombie","infected_skeleton","skeleton","floating_skull","armored_skeleton","thrower_skeleton","bat") var enemy = "skeleton"


var enemy_objects = [
	#preload("res://objects/enemies/Zombie.tscn"),
	preload("res://objects/enemies/InfectedSkeleton.tscn"),
	#preload("res://objects/enemies/Skeleton.tscn"),
	preload("res://objects/enemies/FloatingSkull.tscn"),
	preload("res://objects/enemies/ArmoredSkeleton.tscn"),
	preload("res://objects/enemies/ThrowerSkeleton.tscn"),
	#preload("res://objects/enemies/Bat.tscn"),
]
var enemy_instance = null

signal enemy_invoked

func _ready():
	$vfx_invoke_enemy.frame = 15
	pass

#llamado de manera externa
func invoke():
	$AnimationPlayer.stop(true)
	$AnimationPlayer.play("invoke")

func spawn():
	randomize()
	var selected_enemy = randi() % 4

	enemy_instance = enemy_objects[selected_enemy].instance()
	enemy_instance.global_position = global_position
	Functions.get_main_level_scene().add_child(enemy_instance)
	enemy_instance = null
	Audio.play_sfx("eva_proyectile_shoot")
	emit_signal("enemy_invoked")
