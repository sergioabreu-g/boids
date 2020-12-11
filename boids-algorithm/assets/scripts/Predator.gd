extends Node2D

export (float) var acceleration
export (float) var maxSpeed

var _vel = Vector2.ZERO

func _process(delta):
	var targetPos = get_viewport().get_mouse_position()
	
	if (targetPos != position):
		_vel += (targetPos - position).clamped(acceleration) * delta
		_vel = _vel.clamped(maxSpeed)
		position = position + (_vel * delta)
		
		look_at(position + _vel)
		rotation += PI / 2
