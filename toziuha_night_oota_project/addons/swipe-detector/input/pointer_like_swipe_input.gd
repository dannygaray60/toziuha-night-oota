extends "event_swipe_input.gd"

var press_event
var motion_event

func _init(detector, press_event, motion_event).(detector):
  self.press_event = press_event
  self.motion_event = motion_event

func event_types():
  return [press_event, motion_event]

func extract_pos(event):
  return event.position

func process_event(event, delta, state):
  if event is press_event:
    if event.is_pressed():
      state.swiping = true
    else:
      state.swiping = false
      detector.process_swipe(delta, state.area)

  state.point = extract_pos(event)

  detector.process_swipe(delta, state.area)
