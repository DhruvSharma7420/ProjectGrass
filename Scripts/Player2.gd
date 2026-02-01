extends Area2D

var player_id: int = 2


var _accel: float = 0.0
var _steerstrength: float = 0.0
var _topspeedF: float = 0.0
var _topspeedR: float = 0.0
var _velocity: float = 0.0
var friction: float = 0.0
var mode: int = 0
var acceleratemode = 0
var 	speedmode = 1
var _throttle: float = 0.0
var _steer: float = 0.0
var boost = 1.3

var base_max_speed = 380
var base_steer_strength = 5.0
var base_accel = 150

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("player")
	_accel = base_accel
	_steerstrength = base_steer_strength
	_topspeedF = base_max_speed
	_topspeedR = (0 - base_max_speed)/2
	friction = 300

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var accelpressed = Input.get_action_strength("player2forward")
	var reversepressed = Input.get_action_strength("player2down")
	_steer = Input.get_axis("player2left", "player2right")
	
	apply_rotation(delta)
	if Input.is_action_just_pressed("Player2changemode"):
		if mode < 2:
			mode += 1
		else:
			mode = 0
		changemode(mode)
	print(mode)
	print(_velocity)
	
	if accelpressed > 0:
		print ("1")
		_velocity += _accel * delta
	elif reversepressed > 0 and accelpressed == 0:
		print("2")
		_velocity -= _accel * delta
	else:
		_steer = 0
		if _velocity > 5:
			print ("3")
			_velocity -= friction * delta
		elif _velocity < -5:
			print ("4")
			_velocity += friction * delta
		else:
			print ("5")
			_velocity = 0

func _physics_process(delta: float) -> void:
	position -= transform.y * _velocity * delta
	_velocity = clampf(_velocity, _topspeedR, _topspeedF)

func apply_rotation(delta: float) -> void:
	print("ROTATING")
	print(_steer)
	if _velocity > 5 or _velocity < -5:
		rotate(_steerstrength * delta * _steer)
	print("ROTATING FINISHED")

func changemode(_delta: float) -> void:
	if mode == acceleratemode:
		_accel *= boost
		_topspeedF = base_max_speed
		_steerstrength = base_steer_strength
	elif mode == speedmode:
		_topspeedF *= boost
		_accel =  base_accel
		_steerstrength = base_steer_strength
	else:
		_steerstrength *= boost
		_accel =  base_accel
		_topspeedF = base_max_speed
