# SwipeMath utility class

func calculate_time(speed_vector, position, origin=Vector2(0,0)):
  var distance = position.distance_to(origin)
  var speed = speed_vector.distance_to(Vector2(0,0))
  return distance / speed
