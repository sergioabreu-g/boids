extends Node2D

class_name Boid

@export var maxVelocity: float = 280
@export var maxAcceleration: float = 1000
@export var rotationOffset: float = PI/2

@export var baseColor: Color
@export var specialColor: Color
@export var colorTransitionSpeed: float = 1

@export var syncTrail: bool = true
@export var trail: NodePath
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
	
	velocity = Vector2(randf_range(-maxVelocity, maxVelocity),
						randf_range(-maxVelocity, maxVelocity))
	
func _process(delta):
	velocity += acceleration.limit_length(maxAcceleration * delta)
	velocity = velocity.limit_length(maxVelocity)
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
