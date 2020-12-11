extends Line2D


export (float) var pointDuration = 1
export (int) var maxPoints = 200

var _times = []
var _timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)

func _process(delta):
	_timer += delta
	
	if (_times.size() > 0):
		while (_times[0] <= _timer or _times.size() > maxPoints):
			remove_point(0)
			_times.remove(0)
	
	global_position = Vector2.ZERO
	add_point(get_parent().global_position)
	_times.append(_timer + pointDuration)
