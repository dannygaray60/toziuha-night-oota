# State for a detection instance

var area_name
var capturing = false
var gesture
var last_update_delta
var was_swiping

func _init(area_name=null):
  self.area_name = area_name
  capturing = false
  gesture   = null
  last_update_delta = null
  was_swiping = false
