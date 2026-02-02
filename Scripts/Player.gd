extends CharacterBody2D

var player_id: int = 0

var _accel: float = 0.0
var _steerstrength: float = 0.0
var _topspeedF: float = 0.0
var _topspeedR: float = 0.0
var _velocity: float = 0.0
var friction: float = 0.0
var brakingforce: float = 0.0
var mode: int = 0
var acceleratemode = 0
var speedmode = 1
var _steer: float = 0.0


var base_max_speed = 500
var base_steer_strength = 1
var base_accel = 70

var boost_speed = 1.25   # speed mode
var boost_accel = 1.6    # accel mode
var boost_grip = 2     # grip mode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("player")
	match player_id:
		0:
			$Sprite2D.texture = load("res://Media/Car/P1Default.png")
			global_position = Vector2(500, 5809)
		1:
			$Sprite2D.texture = load("res://Media/Car/P2Default.png")
			global_position = Vector2(700, 5809)

	_accel = base_accel
	_steerstrength = base_steer_strength
	_topspeedF = base_max_speed
	_topspeedR = (0 - base_max_speed) / 2.0
	friction = 3
	brakingforce = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var accelpressed = Input.get_action_strength("player" + str(player_id + 1) + "forward")
	var reversepressed = Input.get_action_strength("player" + str(player_id + 1) + "down")
	_steer = Input.get_axis("player" + str(player_id + 1) + "left", "player" + str(player_id + 1) + "right")
	
	apply_rotation(delta)
	if Input.is_action_just_pressed("Player" + str(player_id + 1) + "changemode"):
		if mode < 2:
			mode += 1
		else:
			mode = 0
		changemode(mode)
	
	if accelpressed > 0:
		if _velocity < _topspeedF:
			if _velocity >= 0:
				_velocity += _accel * delta
			elif _velocity < 0:
				_velocity += (_accel * brakingforce) * delta
		else:
			_velocity -= friction * delta
	elif reversepressed > 0 and accelpressed == 0:
		if _velocity > 0:
			_velocity -= (friction + _accel) * brakingforce * delta
		else:
			_velocity -= (friction + _accel) * delta
	else:
		_steer = 0
		if _velocity > 1:
			_velocity -= friction * delta
		elif _velocity < -1:
			_velocity += friction * delta
		else:
			_velocity += accelpressed * delta

func _physics_process(delta: float) -> void:
	velocity = -transform.y * _velocity
	move_and_slide()

	if get_slide_collision_count() > 0:
		_velocity *= 0.4  # lose 60% speed on impact
	

func apply_rotation(delta: float) -> void:
	var speed_ratio = abs(_velocity) / _topspeedF
	speed_ratio = clamp(speed_ratio, 0.1, 1.0) # minimum turning at low speed

	if abs(_velocity) > 5:
		rotate(_steerstrength * speed_ratio * delta * _steer)

func changemode(_delta: float) -> void:
	_accel = base_accel
	_steerstrength = base_steer_strength
	_topspeedF = base_max_speed

	if mode == acceleratemode:
		_accel *= boost_accel
		_topspeedF *= 0.5
		$Sprite2D.texture = load("res://Media/Car/P" + str(player_id + 1) + "Accel.png")

	elif mode == speedmode:
		_topspeedF *= boost_speed
		_steerstrength *= 0.7
		$Sprite2D.texture = load("res://Media/Car/P" + str(player_id + 1) + "Speed.png")

	else: # grip mode
		_steerstrength *= boost_grip
		brakingforce += (boost_grip * 10)
		_accel *= 0.6
		$Sprite2D.texture = load("res://Media/Car/P" + str(player_id + 1) + "Grip.png")
