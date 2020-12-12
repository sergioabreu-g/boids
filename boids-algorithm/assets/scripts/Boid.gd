extends Node2D

class_name Boid

export (float) var maxVelocity = 280
export (float) var maxAcceleration = 1000
export (float) var rotationOffset = PI/2

export (Color) var baseColor : Color
export (Color) var specialColor : Color
export (float) var colorTransitionSpeed = 1

export (bool) var syncTrail = true
export (NodePath) var trail
var trailRef : Line2D

var velocity := Vector2.ZERO
var acceleration := Vector2.ZERO

var neighbors := []
var neighborsDistances := []
var timeOutOfBorders := 0.0

var targetColor := baseColor

func _ready():
	trailRef = get_node(trail)
	modulate = targetColor
	
	velocity = Vector2(rand_range(-maxVelocity, maxVelocity),
						rand_range(-maxVelocity, maxVelocity))
	
func _process(delta):
	velocity += acceleration.clamped(maxAcceleration * delta)
	velocity = velocity.clamped(maxVelocity)
	acceleration.x = 0
	acceleration.y = 0
	
	position += velocity * delta
	
	look_at(position + velocity)
	rotation += rotationOffset
	
	var targetColorPercent = delta * colorTransitionSpeed
	modulate = modulate * (1 - targetColorPercent) + targetColor * targetColorPercent
	
	if (syncTrail):
		var gradient = trailRef.gradient
		for i in range(gradient.colors.size()):
			var nextColor = modulate
			nextColor.a = gradient.colors[i].a
			gradient.set_color(i, nextColor)
