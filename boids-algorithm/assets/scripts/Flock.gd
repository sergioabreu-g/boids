extends Node2D

# General configuration
export (PackedScene) var boidScene : PackedScene
export (int) var numberOfBoids = 140
export (float) var visualRange = 130
export (float) var separationDistance = 80
export (NodePath) var predator
export (float) var predatorMinDist = 300
export (int) var maxNeighborsColor = 20
var _predatorRef

# Rule weights
export (float) var cohesionWeight = 0.3
export (float) var separationWeight = 50
export (float) var alignmentWeight = 1

export (float) var bordersWeight = 300
export (float) var predatorWeight = 500

var _boids = []
var _envDims

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	randomize()
	_envDims = get_viewport_rect().size
	_predatorRef = get_node(predator)
	
	for i in range(numberOfBoids):
		var instance = boidScene.instance()
		add_child(instance)
		_boids.append(instance)
		
		var x = rand_range(0, _envDims.x)
		var y = rand_range(0, _envDims.y)
		instance.set_position(Vector2(x, y))

func _process(delta):
	_detectNeighbors()
	
	_cohesion()	
	_separation()
	_alignment()
	
	_borders(delta)
	_escapePredator()
	
	_calculateColor()

func _detectNeighbors():
	for i in range(_boids.size()):
		_boids[i].neighbors.clear()
		_boids[i].neighborsDistances.clear()
	
	for i in range(_boids.size()):		
		for j in range(i+1, _boids.size()):
			var distance = _boids[i].get_position().distance_to(_boids[j].get_position())
			if (distance <= visualRange):
				_boids[i].neighbors.append(_boids[j])
				_boids[j].neighbors.append(_boids[i])
				_boids[i].neighborsDistances.append(distance)
				_boids[j].neighborsDistances.append(distance)

func _cohesion():
	for i in range(_boids.size()):
		var neighbors = _boids[i].neighbors
		
		if (neighbors.empty()):
			continue;
		
		var averagePos = Vector2(0, 0)
		for closeBoid in neighbors:
			averagePos += closeBoid.get_position()
		averagePos /= neighbors.size()
		
		var direction = averagePos - _boids[i].get_position()
		_boids[i].acceleration += direction * cohesionWeight

func _separation():
	for i in range(_boids.size()):
		var neighbors = _boids[i].neighbors
		var distances = _boids[i].neighborsDistances
		
		if (neighbors.empty()):
			continue;
			
		for j in range(neighbors.size()):
			if (distances[j] >= separationDistance):
				continue
			
			var distMultiplier = 1 - (distances[j] / separationDistance)
			var direction = _boids[i].get_position() - neighbors[j].get_position()
			direction = direction.normalized()
			_boids[i].acceleration += direction * distMultiplier * separationWeight
			
func _alignment():
	for i in range(_boids.size()):
		var neighbors = _boids[i].neighbors
		
		if (neighbors.empty()):
			continue;
		
		var averageVel = Vector2(0, 0)
		for j in range(neighbors.size()):
			averageVel += neighbors[j].velocity
		averageVel /= neighbors.size()
		
		_boids[i].acceleration += averageVel * alignmentWeight


func _borders(delta):
	for boid in _boids:
		var pos = boid.get_position()
		
		if (pos.x < 0 or pos.x > _envDims.x or pos.y < 0 or pos.y > _envDims.y):
			boid.timeOutOfBorders += delta
			var midPoint = _envDims / 2
			var dir = (midPoint - boid.get_position()).normalized()
			boid.acceleration += dir * boid.timeOutOfBorders * bordersWeight
		else:
			boid.timeOutOfBorders = 0

func _escapePredator():
	for boid in _boids:
		var dist = boid.get_position().distance_to(_predatorRef.get_position())
		if (dist < predatorMinDist):
			var dir = (boid.get_position() - _predatorRef.get_position()).normalized()
			var multiplier = sqrt(1 - (dist / predatorMinDist))
			boid.acceleration += dir * multiplier * predatorWeight


func _calculateColor():
	for boid in _boids:
		if (boid.neighbors.empty()):
			continue
		
		var specialColorPercent = float(boid.neighbors.size()) / maxNeighborsColor
		var baseColorPercent = 1 - specialColorPercent
		boid.targetColor = boid.baseColor * baseColorPercent + boid.specialColor * specialColorPercent
