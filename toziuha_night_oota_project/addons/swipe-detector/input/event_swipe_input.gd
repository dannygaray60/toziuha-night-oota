extends "swipe_input.gd"

const InputState = preload("input_state.gd" )

var states

func _init(detector).(detector):
  states = {}

func area_name(area):
  if area != null:
    return area.get_name()
  else:
    return '_singleton'

func state(area):
  if not states.has(area_name(area)):
    states[area_name(area)] = InputState.new(area)
  return states[area_name(area)]

func event_types():
  return []

func valid_event(event):
  var is_valid = false
  for type in event_types():
    if event is type:
      is_valid = true
      break
  return is_valid

func process_area_input(viewport, event, shape_id, area):
  process_input(event, area)

func process_input(event, area=null):
  if valid_event(event):
    var state = state(area)
    if state.last_time == null:
      state.delta = 0.0
    else:
      state.delta = (OS.get_ticks_msec() - state.last_time) / 1000.0

    process_event(event, state.delta, state)
    state.last_time = OS.get_ticks_msec()

func process_event(event, delta, state):
  pass

func swiping(area):
  return state(area).swiping

func swipe_point(area):
  return state(area).point
