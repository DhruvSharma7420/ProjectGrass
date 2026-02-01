extends Area2D

var player_id: int = 1

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


var boost_speed = 1.7
var boost_accel = 40
var boost_grip = 1.4
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
	var accelpressed = Input.get_action_strength("player1forward")
	var reversepressed = Input.get_action_strength("player1down")
	_steer = Input.get_axis("player1left", "player1right")
	
	apply_rotation(delta)
	if Input.is_action_just_pressed("Player1changemode"):
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
		_accel *= boost_accel
		_topspeedF = base_max_speed - 100
		_steerstrength = base_steer_strength
		$Sprite2D.texture = load("res://Media/Car/P1Accel.png")
	elif mode == speedmode:
		_topspeedF *= boost_speed
		_accel =  base_accel
		_steerstrength = base_steer_strength - 2
		$Sprite2D.texture = load("res://Media/Car/P1Speed.png")
	else:
		_steerstrength *= boost_grip
		_accel =  base_accel - 20
		_topspeedF = base_max_speed
		$Sprite2D.texture = load("res://Media/Car/P1Grip.png")
