extends Node2D

@export var acceleration: float
@export var maxSpeed: float

var _vel = Vector2.ZERO

func _process(delta):
	var targetPos = get_viewport().get_mouse_position()
	
	if (targetPos != position):
		_vel += (targetPos - position).limit_length(acceleration) * delta
		_vel = _vel.limit_length(maxSpeed)
		position = position + (_vel * delta)
		
		look_at(position + _vel)
		rotation += PI / 2
