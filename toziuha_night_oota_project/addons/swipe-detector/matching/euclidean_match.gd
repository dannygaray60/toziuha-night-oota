extends "gesture_match.gd"


const EuclideanSimilarityAlgorithm = preload("euclidean_similarity_algorithm.gd")


func _init(sample, pattern, threshold).(sample, pattern, threshold):
  pass

func similarity_algorithm():
  return EuclideanSimilarityAlgorithm.new()
