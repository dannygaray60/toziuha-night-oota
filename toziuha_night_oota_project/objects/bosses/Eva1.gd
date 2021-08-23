extends KinematicBody2D

signal cl_gas_show
signal cl_gas_hide
signal defeated

var Enemy = load("res://scripts/enemy.gd").new()


var i = 0

var proyectile1 = preload("res://objects/EvaProyectile1.tscn")
var proyectile2 = preload("res://objects/EvaProyectile2.tscn")
var spawn_object = null


var id = "boss_eva1"

var hp_max = Vars.enemy[id]["hp_max"]
var hp_now = hp_max

var anim_state_machine

#velocidad de movimiento
var velocity = Vector2()
#direcion en x o y
var direction = Vector2()

var facing = -1
var state = "idle"
var gravity = 600
var speed = 220

#fase de la pelea
var battle_phase = 0

var gas_atk = 0 # si es cero se da el ataque de gas

func _process(_delta):
	ScreenDebugger.dict["phase"] = str(battle_phase)

func _ready():
	
	$ElementalCircuit.scale = Vector2(0,0)
	
	#Enemy.connect("collision_with_player",self,"_on_collision_with_player")
	anim_state_machine = $AnimationTree.get("parameters/playback")
	
	Enemy.update_facing(self,$Sprite)
	
	change_state("idle")
	


func _physics_process(delta):

	if is_on_floor() and state in ["idle","dead"]:
		velocity.x = 0

	velocity.y += gravity*delta
	
	velocity = move_and_slide(velocity, Vector2.UP,true)
	
	Enemy.check_body_collisions(self)


func start_battle():
	#song...
	Audio.play_voice("eva-laugh")
	Functions.get_main_level_scene().get_node("Hud").set_boss_bar_max(Vars.enemy[id]["hp_max"])
	Functions.get_main_level_scene().get_node("Hud").set_boss_bar_visible()
	$TimerChangePattern.start(1)

func hurt(_total_atk,_global_position):
	
	if $TimerHurt.get_time_left() == 0 and state != "dead" and hp_now > 0:
		
		#sonido de dolor randomizado
		var voices = ["none","none","eva-damage1","eva-damage2","eva-damage3","eva-damage4","eva-damage5","eva-damage6"]
		var selected_voice = 0
		randomize()
		selected_voice = randi() % voices.size()
		if voices[selected_voice] != "none":
			Audio.play_voice(voices[selected_voice])
	
		$TimerHurt.start()
		
		$Sprite.modulate = Color(1,0,0,1)
		
		Audio.play_sfx("hit4")
		
		if state == "atk2":
			_total_atk += 8
		
		Enemy.apply_damage(self,_total_atk,_global_position)
		
		if hp_now <= (hp_max/2) :
			battle_phase = 1
		
		Functions.get_main_level_scene().get_node("Hud").update_boss_bar(hp_now)

		#muerte de jefe
		if hp_now <= 0:
			$TimerChangePattern.stop()
			stop_circuit()
			$Sprite.modulate = Color(1,1,1,1)
			Audio.stop_sfx("precharge_elemental_circuit_eva")
			Functions.get_main_level_scene().get_node("Hud").show_flash()
			Functions.get_main_level_scene().get_node("Hud").set_boss_bar_visible(false)
			#Enemy.open_doors_on_boss_death(self)
			Audio.stop_music()
			#visible = false
			emit_signal("defeated")
			state = "dead"
			anim_state_machine.travel("defeated")
			#queue_free()
			return
		
		yield($TimerHurt,"timeout")
		Enemy.update_facing(self,$Sprite)
		$Sprite.modulate = Color(1,1,1,1)
		
func change_state(new_state):
	if new_state != state and state != "dead":
		Enemy.update_facing(self,$Sprite)
		state = new_state
		anim_state_machine.travel(state)

#embestir hacia la izquierda o derecha
func _move_to():
	#Enemy.update_facing(self,$Sprite)
	#facing = Functions.get_new_facing_with_player(self,Functions.get_main_level_scene().get_player())
	velocity.x += speed * facing
	Audio.play_sfx("spike_slash2")

func start_circuit():
	
	#reestablecer los decibelios por defecto ya que se usará fadein de sonido
	#Audio.get_node("sfx/precharge_elemental_circuit_eva").volume_db = 3
	Audio.play_sfx("precharge_elemental_circuit_eva",true)
	
	#de vez en cuando dar señal para hacer aparecer gas de cloro
	randomize()
	gas_atk = randi() % 4
	
	if gas_atk == 0:
		#mostrar de color diferente el circuito
		$ElementalCircuit.modulate = "ffde05"
	else:
		$ElementalCircuit.modulate = "ffffff"
	
	$ElementalCircuit/Tween.stop_all()
	$ElementalCircuit/AnimationPlayer.play("spin")
	$ElementalCircuit/Tween.interpolate_property($ElementalCircuit,"scale",Vector2(0,0),Vector2(1,1),0.7)
	$ElementalCircuit/Tween.start()
func stop_circuit():
	Audio.stop_sfx("precharge_elemental_circuit_eva")
	change_state("idle")
	$ElementalCircuit/Tween.stop_all()
	$ElementalCircuit/AnimationPlayer.stop()
	$ElementalCircuit/Tween.interpolate_property($ElementalCircuit,"scale",$ElementalCircuit.scale,Vector2(0,0),0.5)
	$ElementalCircuit/Tween.start()

func _on_CircuitTween_tween_completed(_object, key):
	if key == ":scale" and $ElementalCircuit.scale == Vector2(1,1):
		i = 0

		if gas_atk == 0:
			#mostrar de color diferente el circuito
			$ElementalCircuit.modulate = "ffde05"
			emit_signal("cl_gas_show")
			$Timer.start(5)
			yield($Timer,"timeout")
			stop_circuit()
			$TimerChangePattern.start(1.5)
			emit_signal("cl_gas_hide")
			return

		
		if battle_phase == 0:
			
			while i < 3:
				$Timer.start(0.7)
				yield($Timer,"timeout")
				spawn_object = proyectile1.instance()
				spawn_object.global_position = $ElementalCircuit.global_position
				Functions.get_main_level_scene().add_child(spawn_object)
				i += 1
		else:
			
			while i < 4:
				$Timer.start(1)
				yield($Timer,"timeout")
				spawn_object = proyectile2.instance()
				spawn_object.global_position = $ElementalCircuit.global_position
				Functions.get_main_level_scene().add_child(spawn_object)
				i += 1			
		
		stop_circuit()

		$TimerChangePattern.start(0.5)

func _on_TimerChangePattern_timeout():
	
	if hp_now <= 0:
		return
	
	var patterns = []
	var selected_pattern = 0

	if battle_phase == 0:
		patterns = ["atk2","atk2","atk2","atk2","atk3","atk3","atk3"]
	else:
		patterns = ["atk3","atk3","atk3","atk2","atk2","atk3","atk2","atk2"]
		
	randomize()
	selected_pattern = randi() % patterns.size()

	change_state(patterns[selected_pattern])

	if patterns[selected_pattern] == "idle":
		$TimerChangePattern.start(1)
		


func _on_Eva1_tree_exiting():
	Audio.stop_sfx("precharge_elemental_circuit_eva")
