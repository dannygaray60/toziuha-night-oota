extends Node
class_name PhysicsHelper

static func calculate_arc_velocity(point_a, point_b, arc_height, up_gravity=500, down_gravity=null):
	
	if down_gravity==null:
		down_gravity = up_gravity
		
	var velocity = Vector2()
	
	var displacement = point_b - point_a
	
	if displacement.y > arc_height:
		var time_up = sqrt(-1*arc_height/float(up_gravity))
		var time_down = sqrt(1*(displacement.y-arc_height)/float(down_gravity))
		
		velocity.y = -sqrt(-1*up_gravity*arc_height)
		velocity.x = displacement.x/float(time_up+time_down)

	return velocity
