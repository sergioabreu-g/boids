extends Node2D

class_name Boid

export (float) var maxVelocity
export (float) var maxAcceleration
export (float) var rotationOffset = PI/2

export (Color) var baseColor : Color
export (Color) var specialColor : Color
export (float) var colorTransitionSpeed = 1

var velocity := Vector2.ZERO
var acceleration := Vector2.ZERO

var neighbors := []
var neighborsDistances := []
var timeOutOfBorders := 0.0

var targetColor := baseColor

func _ready():
	modulate = targetColor
	
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
