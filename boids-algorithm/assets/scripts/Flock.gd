extends Node2D

# General configuration
export (PackedScene) var boidScene : PackedScene
export (int) var numberOfBoids
export (float) var acceleration
export (float) var maxSpeed
export (float) var visualRange
export (float) var separationDistance
export (NodePath) var predator
export (float) var predatorMinDist
var _predatorRef

# Rule weights
export (float) var cohesionWeight
export (float) var separationWeight
export (float) var alignmentWeight

export (float) var bordersWeight
export (float) var predatorWeight


var _boids = []
var _velocities = []
var _accelerations = []
var _neighbors = []
var _distances = []
var _timeOutOfBorders = []

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
		_velocities.append(Vector2(rand_range(0, maxSpeed), rand_range(0, maxSpeed)))
		_accelerations.append(Vector2(0, 0))
		_neighbors.append([])
		_distances.append([])
		_timeOutOfBorders.append(0)
		
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
	
	_updateBoids(delta)

func _updateBoids(delta):
	for i in range(_boids.size()):
		_velocities[i] += _accelerations[i].clamped(acceleration * delta)
		_velocities[i] = _velocities[i].clamped(maxSpeed)
		_accelerations[i].x = 0
		_accelerations[i].y = 0
		
		var nextPos = _boids[i].get_position() + (_velocities[i] * delta)
		_boids[i].set_position(nextPos)
		
		_boids[i].look_at(_boids[i].get_position() + _velocities[i])
		_boids[i].rotation += PI/2

func _detectNeighbors():
	for i in range(_neighbors.size()):
		_neighbors[i].clear()
		_distances[i].clear()
	
	for i in range(_boids.size()):		
		for j in range(i+1, _boids.size()):
			var distance = _boids[i].get_position().distance_to(_boids[j].get_position())
			if (distance <= visualRange):
				_neighbors[i].append(j)
				_neighbors[j].append(i)
				_distances[i].append(distance)
				_distances[j].append(distance)

func _cohesion():
	for i in range(_neighbors.size()):
		if (_neighbors[i].size() == 0):
			continue;
		
		var averagePos = Vector2(0, 0)
		for j in _neighbors[i]:
			averagePos += _boids[j].get_position()
		averagePos /= _neighbors[i].size()
		
		var direction = averagePos - _boids[i].get_position()
		_accelerations[i] += direction * cohesionWeight

func _separation():
	var velocity = Vector2(0, 0)
	
	for i in range(_neighbors.size()):
		if (_neighbors[i].size() == 0):
			continue;
			
		for j in range(_neighbors[i].size()):
			if (_distances[i][j] >= separationDistance):
				continue
			
			var distMultiplier = 1 - (_distances[i][j] / separationDistance)
			var direction = _boids[i].get_position() - _boids[_neighbors[i][j]].get_position()
			direction = direction.normalized()
			_accelerations[i] += direction * distMultiplier * separationWeight
			
func _alignment():
	for i in range(_neighbors.size()):
		if (_neighbors[i].size() == 0):
			continue;
		
		var averageVel = Vector2(0, 0)
		for j in range(_neighbors[i].size()):
			averageVel += _velocities[_neighbors[i][j]]
		averageVel /= _neighbors[i].size()
		
		_accelerations[i] += averageVel * alignmentWeight


func _borders(delta):
	for i in range(_boids.size()):
		var pos = _boids[i].get_position()
		if (pos.x < 0 or pos.x > _envDims.x or pos.y < 0 or pos.y > _envDims.y):
			_timeOutOfBorders[i] += delta
			var midPoint = _envDims / 2
			var dir = (midPoint - _boids[i].get_position()).normalized()
			_accelerations[i] += dir * _timeOutOfBorders[i] * bordersWeight
		else:
			_timeOutOfBorders[i] = 0

func _escapePredator():
	for i in range(_boids.size()):
		var dist = _boids[i].get_position().distance_to(_predatorRef.get_position())
		if (dist < predatorMinDist):
			var dir = (_boids[i].get_position() - _predatorRef.get_position()).normalized()
			var multiplier = sqrt(1 - (dist / predatorMinDist))
			_accelerations[i] += dir * multiplier * predatorWeight




