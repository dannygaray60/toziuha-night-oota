
const EuclideanSimilarityAlgorithm = preload("euclidean_similarity_algorithm.gd")

func similarity_score(pointsA, pointsB):
  return EuclideanSimilarityAlgorithm.new().similarity_score(delta_chain(pointsA), delta_chain(pointsB))

func delta_chain(points):
  var chain = []
  var previous_point
  for point in points:
    if previous_point != null:
      var angle = rad2deg(Vector2(0,0).angle_to_point(point - previous_point))
      chain.append(angle)
    previous_point = point
  return chain
