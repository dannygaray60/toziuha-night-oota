extends Node

const FOUR_DIRECTIONS_MODE = 'Four Directions'
const EIGHT_DIRECTIONS_MODE = 'Eight Directions'

var Directions = preload('directions.gd').new()

# Stores swipe data

var area # Area were swipe was performed (null if not using areas)

var points # list of points
var duration # in seconds

var relative # SwipeGesture with relative points

var distance
var distance_points

var directions_mode

func _init(area=null, points=[], directions_mode=EIGHT_DIRECTIONS_MODE):
  self.area = area
  self.points = points
  self.duration = 0
  set_directions_mode(directions_mode)

func set_directions_mode(value):
  self.directions_mode = value

func get_area():
  return area

func is_area_detection():
  return area != null

func get_distance():
  if distance == null and distance_points != points.size():
    distance = calculate_distance()
    distance_points = points.size()
  return distance

func calculate_distance():
  var last = points[0]
  var distance = 0.0
  for point in points:
    distance += last.distance_to(point)
    last = point
  return distance

func get_speed():
  return get_distance() / get_duration()

func get_duration():
  return duration

func add_duration(delta):
  duration += delta
  return self

func add_point(point):
  points.append(point)
  return self

func first_point():
  return points[0]

func last_point():
  return points[points.size() - 1]

func to_string():
  return ('Swipe ' + str(first_point()) + ':' + str(last_point()) +
       ' ' + str(points.size()) + ', length: ' + str(duration))

func get_curve():
  # Get a Curve2D from swipe points
  var curve = Curve2D.new()
  for point in points:
    curve.add_point(point)
  return curve

func get_points():
  return points

func get_point(index):
  return points[index]

func point_count():
  return points.size()

func relative():
  if relative == null:
    relative = duplicate()
    relative.points = []
    for point in get_points():
      relative.points.append(point - first_point())
  return relative

func scale(scale):
  var scaled = duplicate()
  scaled.relative = null
  scaled.points = []
  for point in get_points():
    scaled.points.append(Vector2(point.x * scale.x, point.y * scale.y))
  return scaled

func get_direction_angle():
  return first_point().angle_to_point(last_point()) + PI/2

func get_direction_vector():
  # Normalized direction vector
  return (last_point() - first_point()).normalized()

func get_direction_index(mode=null):
  if mode == null:
    mode = directions_mode
  var angle_normalized = get_direction_angle() * -1
  if mode == FOUR_DIRECTIONS_MODE:
    var percentage = angle_normalized/(PI*2.0) + 1.0/8
    return int(floor(percentage * 4)) % 4 * 2
  elif mode == EIGHT_DIRECTIONS_MODE:
    var percentage = angle_normalized/(PI*2.0) + 1.0/16
    return int(floor(percentage * 8)) % 8
  else:
    print('ERROR: Invalid directions_mode')
    return 0

func get_direction(mode=null):
  return Directions.DIRECTIONS[get_direction_index(mode)]
