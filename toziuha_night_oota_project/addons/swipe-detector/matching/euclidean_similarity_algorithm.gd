func similarity_score(xs, ys):
  var sum = 0
  for i in range(min(xs.size(), ys.size())):
    sum += point_similarity_score(xs[i], ys[i])
  return sum / float(min(xs.size(), ys.size()))

func point_similarity_score(x, y):
  if TYPE_VECTOR2 == typeof(x):
    return x.distance_to(y)
  else:
    return abs(x - y)
