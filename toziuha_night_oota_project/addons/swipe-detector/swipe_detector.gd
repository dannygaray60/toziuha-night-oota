extends Node


###
# Swipe Detector implementation
# Captures a gesture and stores a history of all
# captured gestures.


# Constant Imports

const SwipeGesture = preload("swipe_gesture.gd")

const DetectionState = preload("detection_state.gd")
const GesturePattern = preload("gesture/pattern.gd")

const ShapeMatch = preload("matching/shape_match.gd")
const EuclideanMatch = preload("matching/euclidean_match.gd")


# Singleton Imports

var Directions = preload("directions.gd").new()
var InputProvider = preload("input/input_provider.gd").new()


## Signals

# Signal triggered when swipe captured
signal swiped(gesture)
signal swipe_ended(gesture) # alias for `swiped`

# Signal triggered when swipe started
signal swipe_started(partial_gesture)

# Signal triggered when gesture is updated
signal swipe_updated(partial_gesture)
signal swipe_updated_with_delta(partial_gesture, delta)

# Signal triggered when swipe failed
# This means the swipe didn't pass thresholds and requirements
# to be detected as swipe.
signal swipe_failed()

# Signal triggered when gesture detected
signal pattern_detected(pattern_name, actual_gesture)

## Exported Variables

# Enable or disable gesture detection
export var detect_gesture = true setget detect

# Determine process method to be used
const PROCESS_FIXED = 'Fixed'
const PROCESS_IDLE  = 'Idle'
export (String, 'Idle', 'Fixed') var process_method = PROCESS_FIXED

# Minimum distance between points
export var distance_threshold = 25.0

# Indicate minimum swipe duration
# "A swipe will be a swipe if it the duration
# is at least {{duration_threshold}} seconds"
export var duration_threshold = 0.05

# Maximum duration
# You can the maximum swipe duration
export var limit_duration = false
export var maximum_duration = -1.0

# Minimum swipe points
# "A swipe will be captured if it has at least {{minimum_points}} points
export var minimum_points = 2

# Maximum points
# You can limit points captured so a Swipe will end prematurely
export var limit_points = false
export var maximum_points = -1

# Threshold for gesture detection
export var pattern_detection_score_threshold = 80

# Define the output mode of the get_directions method
# - Four directions mode for output in only four directions (Up/Right/Down/Left)
# - Eight directions mode for output in eight directions
export (String, 'Four Directions', 'Eight Directions') var directions_mode = 'Eight Directions'

# Debug mode: will print debug information
export var debug_mode = false

## Implementation

func debug(message, more1='', more2='', more3=''):
	if debug_mode:
		print('[DEBUG][SwipeDetector] ', message, more1, more2, more3)



onready var gesture_history = []
var swipe_input
onready var ready = true

onready var pattern_detections = {}
onready var detection_areas = []
onready var states

func _ready():
	detection_areas = detect_areas()
	initialize_states()
	swipe_input = InputProvider.get_swipe_input(self)
	set_swipe_process(process_method, detect_gesture)
	add_children_as_patterns()

func detect_areas():
	var areas = []
	for child in get_children():
		if child is Area2D:
			areas.append(child)
	return areas

func state(area):
	if area != null:
		return states[area.get_name()]
	else:
		return states['_singleton']

func initialize_states():
	states = {}
	if detection_areas.size() > 0:
		for area in detection_areas:
			states[area.get_name()] = DetectionState.new(area.get_name())
	else:
		states['_singleton'] = DetectionState.new()

func _input(ev):
	swipe_input.process_input(ev)

func connect_detection_areas():
	for area in detection_areas:
		area.connect('input_event', swipe_input, 'process_area_input', [area])

func set_swipe_process(method, value):
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	if swipe_input.has_method('process_input'):
		if detection_areas.size() > 0:
			set_process_input(false)
			connect_detection_areas()
		else:
			set_process_input(value)
	elif swipe_input.has_method('process'):
		if method == PROCESS_IDLE:
			set_process(value)
		elif method == PROCESS_FIXED:
			set_physics_process(value)

func detect(detect=true):
	if ready == true:
		set_swipe_process(process_method, detect)
		if not detect:
			clean_states()
	return self

func reached_point_limit(area):
	return limit_points and state(area).gesture.point_count() >= maximum_points

func reached_duration_limit(area):
	return limit_duration and state(area).gesture.get_duration() >= maximum_duration

func reached_limit(area):
	return reached_point_limit(area) or reached_duration_limit(area)

func _physics_process(delta):
	swipe_input.process(delta)

func _process(delta):
	swipe_input.process(delta)

func process_swipe(delta, area=null):
	var state = state(area)
	if not state.capturing and swiping_started(area):
		swipe_start(area)
	elif state.capturing and swiping(area) and not reached_limit(area):
		swipe_update(delta, area)
	elif state.capturing and swiping(area) and reached_limit(area):
		swipe_stop(area, true)
	elif state.capturing and not swiping(area):
		swipe_stop(area)
	state.was_swiping = swiping(area)


func clean_states():
	initialize_states()


func swiping_started(area):
	return not state(area).was_swiping and swiping(area)

func swiping(area):
	return swipe_input.swiping(area)


func swipe_point(area):
	return swipe_input.swipe_point(area)


func swipe_start(area):
	var state = state(area)
	var point = swipe_point(area)
	debug('Swipe started on point ', point)
	state.capturing = true
	state.last_update_delta = 0.0
	state.gesture = SwipeGesture.new(area, [], directions_mode)
	add_gesture_data(area, point)
	emit_signal('swipe_started', state.gesture)
	return self


func swipe_stop(area, forced=false):
	var state = state(area)
	var gesture = state.gesture
	if gesture.point_count() > minimum_points and gesture.get_duration() > duration_threshold:

		if forced:
			state.capturing = false

		detect_gestures(gesture)
		debug('Swipe stopped on point ', gesture.last_point(), ' (forced: ' + str(forced) + ')')
		emit_signal('swiped', gesture)
		emit_signal('swipe_ended', gesture)
		gesture_history.append(gesture)
	else:
		debug('Swipe stopped on point ', gesture.last_point(), ' (failed)')
		emit_signal('swipe_failed')
	clean_states()
	return self


func swipe_update(delta, area):
	var state = state(area)
	var gesture = state.gesture
	var point = swipe_point(area)
	state.last_update_delta += delta
	if gesture.last_point().distance_to(point) > distance_threshold:
		debug('Swipe updated with point ', point, ' (delta: ' + str(delta) + ')')
		add_gesture_data(area, point, state.last_update_delta)
		emit_signal('swipe_updated', state.gesture)
		emit_signal('swipe_updated_with_delta', state.gesture, state.last_update_delta)
		state.last_update_delta = 0.0


func add_gesture_data(area, point, delta=0):
	var gesture = state(area).gesture
	gesture.add_point(point)
	gesture.add_duration(delta)
	return self


func history():
	return gesture_history


func set_duration_threshold(value):
	duration_threshold = value
	return self


func set_distance_threshold(value):
	distance_threshold = value
	return self

func points_to_gesture(points, area=null):
	return SwipeGesture.new(area, points)




# Gesture/Curve detection methods

func add_pattern_detection(name, gesture):
	pattern_detections[name] = GesturePattern.new(name, gesture)

func remove_pattern_detections():
	pattern_detections = {}

func remove_pattern_detection(name):
	pattern_detections.erase(name)

func add_children_as_patterns():
	for child in get_children():
		if !child is Area2D:
			var gesture = SwipeGesture.new()
			for point in child.get_children():
				gesture.add_point(point.get_position())
			add_pattern_detection(child.get_name(), gesture)

func detect_gestures(gesture):
	var best_match
	for pattern_name in pattern_detections.keys():
		var actual_match = match_gestures(gesture, pattern_detections[pattern_name])
		if actual_match.is_match() and (best_match == null or actual_match.better_than(best_match)):
			best_match = actual_match
	if best_match != null:
		debug('Matched gesture "', best_match.pattern.name, '" with score ', str(best_match.score()))
		emit_signal('pattern_detected', best_match.pattern.name, gesture)

func match_gestures(gestureA, gestureB):
	return EuclideanMatch.new(gestureA, gestureB, pattern_detection_score_threshold)
