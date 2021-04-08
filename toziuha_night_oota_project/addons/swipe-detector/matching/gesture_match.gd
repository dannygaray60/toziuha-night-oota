# Match a Gesture with another

var sample
var pattern
var score
var threshold

func _init(sampleGesture, patternGesture, threshold):
  self.threshold = threshold
  self.sample = sampleGesture
  self.pattern = patternGesture

func score():
  if score == null:
    var relative_pattern = pattern.gesture.relative()
    var relative_sample  = sample.relative()
    var sample_scale = scale(relative_pattern, relative_sample)
    var pointsA = points(relative_sample.scale(sample_scale))
    var pointsB = points(relative_pattern)

    if pointsA.size() > pointsB.size():
      pointsA = pick_samples(pointsA, pointsB.size())
    elif pointsB.size() > pointsA.size():
      pointsB = pick_samples(pointsB, pointsA.size())

    score = similarity_algorithm().similarity_score(pointsA, pointsB)
  return score

func similarity_algorithm():
  print('Subclass Responsibility!')
  breakpoint

func is_match():
  return score() < threshold

func points(gesture):
  var curve = gesture.get_curve()
  curve.set_bake_interval(min(gesture.get_point(0).distance_to(gesture.get_point(1)), 20))
  return curve.get_baked_points()

func pick_samples(points, pick_count):
  var spacing = points.size()/pick_count
  var samples = []
  for i in range(pick_count):
    samples.append(points[floor(spacing * i)])
  return samples

func scale(gA, gB):
  var minGA = gA.get_point(0)
  var minGB = gB.get_point(0)
  var maxGA = gA.get_point(0)
  var maxGB = gB.get_point(0)
  for i in range(min(gA.get_points().size(), gB.get_points().size())):
    if gA.get_point(i).distance_to(minGA) > minGA.distance_to(maxGA):
      maxGA = gA.get_point(i)
    elif gA.get_point(i).distance_to(maxGA) > minGA.distance_to(maxGA):
      minGA = gA.get_point(i)

    if gB.get_point(i).distance_to(minGB) > minGB.distance_to(maxGB):
      maxGB = gB.get_point(i)
    elif gB.get_point(i).distance_to(maxGB) > minGB.distance_to(maxGB):
      minGB = gB.get_point(i)

  var scale1 = minGA.distance_to(maxGA) / minGB.distance_to(maxGB)

  return Vector2(scale1, scale1)

func better_than(otherMatch):
  return score() > otherMatch.score()
