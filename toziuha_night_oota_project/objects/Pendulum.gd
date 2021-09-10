extends Position2D
#class_name Pendulum

#mover pendulo con izq o der
var move_pendulum = false

var pivot_point:Vector2				 				#point the pendulum rotates around
export (Vector2) var end_position: = Vector2() 		#pendulum itself
var arm_length:float
var angle											#Get angle between position + add godot angle offset

export (float) var gravity = 0.4 * 60
export (float) var damping = 0.995 							#Arbitrary dampening force

var angular_velocity = 0.0
var angular_acceleration = 0.0

var last_direction = "center"

#func _ready()->void:
#	set_start_position(global_position, end_position)

func set_start_position(start_pos:Vector2, end_pos:Vector2, custom_arm_length=0):
	
	pivot_point = start_pos
	end_position = end_pos
	
	if custom_arm_length == 0:
		arm_length = Vector2.ZERO.distance_to(end_position-pivot_point)
	else:
		arm_length = custom_arm_length
		
	if arm_length > 52.278:
		arm_length = 52.278
	elif arm_length < 5:
		arm_length = 5
	
	#calcular angulo entre puntos y luego pasar a deg para usarse en formula de angle
	var angle_deg = end_position.angle_to_point(pivot_point)
	angle_deg = rad2deg(angle_deg)-90
	
	angle = Vector2.ZERO.angle_to(end_position-pivot_point) - deg2rad(angle_deg) #deg2rad(grado del pendulo inicial: de izq 90, 0, -90 der)
	angular_velocity = 0.0
	angular_acceleration = 0.0

func process_velocity(delta:float)->void:
	if move_pendulum:
		angular_acceleration = ((-gravity*delta) / arm_length) *sin(angle)	#Calculate acceleration (see: http://www.myphysicslab.com/pendulum1.html)
		angular_velocity += angular_acceleration				#Increment velocity
		angular_velocity *= damping								#Arbitrary damping
		angle += angular_velocity								#Increment angle
		
		end_position = pivot_point + Vector2(arm_length*sin(angle), arm_length*cos(angle))

func add_angular_velocity(force:float)->void:
	if force != 0 and abs(angular_velocity) < 1:
		angular_velocity += force

func _physics_process(delta)->void:
	game_input()											#example of in game swing kick
	process_velocity(delta)
#	update()												#update draw

func game_input()->void:
	
	#limitar un maximo de angulo para poder balancearse
	if abs(angle) > 0.8:
		return
	
	var dir:float = 0
	if move_pendulum and Input.is_action_just_pressed("ui_right"):
		dir += 1
	elif move_pendulum and Input.is_action_just_pressed("ui_left"):
		dir -= 1
	
	#cooldown para evitar mover repetidamente
#	if $Timer.get_time_left() == 0:
#		$Timer.start()
	add_angular_velocity(dir * 0.02) 						#give a kick to the swing
	
	#aumentar distancia del pendulo o disminuir
	if move_pendulum and Input.is_action_just_pressed("ui_up"):
		Audio.play_sfx("chains2")
		set_start_position(pivot_point,end_position,arm_length-5)
	elif move_pendulum and Input.is_action_just_pressed("ui_down"):
		Audio.play_sfx("chains2")
		set_start_position(pivot_point,end_position,arm_length+5)

#func _draw()->void:
#	draw_line(Vector2.ZERO, end_position - pivot_point, Color.white, 1.0, false)
#	draw_circle(end_position - pivot_point, 3.0, Color.red)
